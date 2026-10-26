"""Regression checks for host-only Codemode builds without Apple/Rust toolchains."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('codemode_artifact', ROOT / 'tools/codemode_artifact.py')
artifact = importlib.util.module_from_spec(spec)
spec.loader.exec_module(artifact)


class ArtifactTests(unittest.TestCase):
    def test_host_key_has_one_target_and_never_queries_ios_sdk(self):
        def run(*args):
            if args[0] == 'git':
                return ''
            if args[0] == 'rustc':
                return 'rustc 1.97.1'
            if args == ('xcodebuild', '-version'):
                return 'Xcode 26.2'
            if args == ('xcrun', '--sdk', 'macosx', '--show-sdk-version'):
                return '26.2'
            self.fail('Unexpected tool/SDK query: ' + repr(args))

        keys = []
        for machine, target in [('arm64', 'aarch64-apple-darwin'),
                                ('x86_64', 'x86_64-apple-darwin')]:
            with self.subTest(machine=machine), patch.object(artifact, 'run', side_effect=run), \
                    patch.object(artifact.platform, 'system', return_value='Darwin'), \
                    patch.object(artifact.platform, 'machine', return_value=machine):
                key, value = artifact.identity()
                self.assertEqual(value['toolchain']['targets'], [target])
                keys.append(key)
        if len(keys) == 2:
            self.assertNotEqual(*keys)

    def test_unsupported_mac_arch_fails(self):
        with patch.object(artifact.platform, 'machine', return_value='unknown'):
            with self.assertRaisesRegex(SystemExit, 'Unsupported macOS architecture'):
                artifact.macos_arch()

    def test_record_and_verify_host_generation_and_reject_other_targets(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            binaries = root / 'binaries'
            binaries.mkdir()
            archive = binaries / 'fjs.xcframework.zip'
            archive.write_bytes(b'assembled macOS archive')
            checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
            archive.with_suffix('.zip.checksum').write_text(checksum)
            record = binaries / 'reveric-build.json'
            generation = root / 'third/fjs/build/darwin-xcframework-macos-arm64/generation'
            composite = generation / 'composites/swiftpm'
            composite.mkdir(parents=True)
            shutil.copyfile(archive, composite / archive.name)
            assets = []
            for extension in ('a', 'dylib'):
                name = 'aarch64-apple-darwin_libfjs.' + extension
                file = generation / 'targets/aarch64-apple-darwin' / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_bytes(b'compiled target ' + extension.encode())
                assets.append({'name': name, 'path': str(file.relative_to(generation)),
                               'sha256': hashlib.sha256(file.read_bytes()).hexdigest()})
            provenance = {'scope': 'cargokit-local-precompiled-generation',
                          'recipe': {'rust_toolchain': artifact.RUST}, 'assets': assets}
            manifest = generation / 'manifest.json'
            manifest.write_text(json.dumps(provenance))
            with patch.multiple(artifact, ROOT=root, ARCHIVE=archive, RECORD=record), \
                    patch.object(artifact, 'identity', return_value=('key', {})), \
                    patch.object(artifact.platform, 'machine', return_value='arm64'), \
                    patch.object(sys, 'argv', ['codemode_artifact.py', 'record', 'fjs-key']), \
                    contextlib.redirect_stdout(io.StringIO()):
                artifact.main()
                self.assertTrue(artifact.verify('key'))
                self.assertFalse(artifact.verify('old-all-apple-key'))
                archive.with_suffix('.zip.checksum').unlink()
                self.assertFalse(artifact.verify('key'))
                archive.with_suffix('.zip.checksum').write_text(checksum)
                provenance['assets'].append({'name': 'aarch64-apple-ios_libfjs.a'})
                manifest.write_text(json.dumps(provenance))
                with self.assertRaisesRegex(SystemExit, 'only the requested macOS target'):
                    artifact.main()
                provenance['assets'].pop()
                manifest.write_text(json.dumps(provenance))
                file.write_bytes(b'changed retained target')
                with self.assertRaisesRegex(SystemExit, 'Retained target differs'):
                    artifact.main()

    def test_verify_app_accepts_single_arch_archive(self):
        with tempfile.TemporaryDirectory() as temporary:
            archive = Path(temporary) / 'fjs.xcframework.zip'
            with zipfile.ZipFile(archive, 'w') as output:
                output.writestr('fjs.xcframework/macos-arm64/fjs.framework/Versions/A/fjs', b'native')
            with patch.object(artifact, 'ARCHIVE', archive), \
                    patch.object(artifact, 'identity', return_value=('key', {})), \
                    patch.object(artifact, 'verify', return_value=True), \
                    patch.object(artifact, 'run', return_value='UUID: UUID-1 (arm64) native'), \
                    patch.object(artifact.platform, 'machine', return_value='arm64'), \
                    patch.object(sys, 'argv', ['codemode_artifact.py', 'verify-app', 'Reveric.app']), \
                    contextlib.redirect_stdout(io.StringIO()):
                artifact.main()


class WrapperTests(unittest.TestCase):
    def test_wrapper_only_requests_selected_macos_target_and_preserves_full_default(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'tool').mkdir()
            (root / 'cargokit').mkdir()
            shutil.copyfile(ROOT / 'third/fjs/tool/build_fjs_xcframework.sh', root / 'tool/build_fjs_xcframework.sh')
            (root / 'cargokit/run_build_tool.sh').write_text('''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_LOG"
while [ "$#" -gt 0 ]; do
  if [ "$1" = --output-dir ]; then output="$2"; fi
  shift
done
mkdir -p "$output/composites/swiftpm"
printf zip > "$output/composites/swiftpm/fjs.xcframework.zip"
printf checksum > "$output/composites/swiftpm/fjs.xcframework.zip.checksum"
''')
            (root / 'tool/assemble_fjs_xcframework.sh').write_text('''#!/bin/sh
printf 'assemble %s\\n' "$*" >> "$TEST_LOG"
''')
            log = root / 'calls.log'
            env = {**os.environ, 'FLUTTER_ROOT': '/unused-sdk', 'TEST_LOG': str(log)}
            for arch, target in [('arm64', 'aarch64-apple-darwin'), ('x86_64', 'x86_64-apple-darwin')]:
                log.write_text('')
                result = subprocess.run(['sh', str(root / 'tool/build_fjs_xcframework.sh'),
                                         '--macos-arch', arch], env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                calls = log.read_text().splitlines()
                self.assertIn('--no-composites --target ' + target, calls[0])
                self.assertEqual(calls[0].count('--target '), 1)
                self.assertNotIn('apple-ios', calls[0])
                self.assertEqual(calls[1], 'assemble --macos-arch ' + arch)
            log.write_text('')
            result = subprocess.run(['sh', str(root / 'tool/build_fjs_xcframework.sh')],
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            calls = log.read_text().splitlines()
            self.assertEqual(len(calls), 1)
            self.assertEqual(calls[0].count('--target '), 5)
            self.assertIn('--target aarch64-apple-ios', calls[0])
            self.assertNotIn('--no-composites', calls[0])

    def test_project_entry_selects_host_arch_and_restores_cache_without_rebuild(self):
        for arch in ('arm64', 'x86_64'):
            with self.subTest(arch=arch), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                (root / 'tools').mkdir()
                (root / 'third/fjs/tool').mkdir(parents=True)
                shutil.copyfile(ROOT / 'tools/build_codemode_runtime.sh', root / 'tools/build_codemode_runtime.sh')
                bin_dir = root / 'bin'
                bin_dir.mkdir()
                (bin_dir / 'dart').write_text('#!/bin/sh\nexit 0\n')
                (bin_dir / 'dart').chmod(0o755)
                scripts = {
                    'uname': '#!/bin/sh\necho Darwin\n',
                    'python3': '''#!/bin/sh
binaries="$TEST_PROJECT/third/fjs/darwin/fjs/Binaries"
case "$2" in
  arch) echo "$TEST_ARCH" ;;
  key) echo "fjs-fixture-$TEST_ARCH" ;;
  verify) test -f "$binaries/reveric-build.json" ;;
  record) printf record > "$binaries/reveric-build.json" ;;
  *) exit 99 ;;
esac
''',
                }
                for name, content in scripts.items():
                    file = bin_dir / name
                    file.write_text(content)
                    file.chmod(0o755)
                (root / 'third/fjs/tool/build_fjs_xcframework.sh').write_text('''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_PROJECT/build.log"
binaries="$TEST_PROJECT/third/fjs/darwin/fjs/Binaries"
mkdir -p "$binaries"
printf archive > "$binaries/fjs.xcframework.zip"
printf checksum > "$binaries/fjs.xcframework.zip.checksum"
''')
                env = {**os.environ, 'TEST_PROJECT': str(root), 'TEST_ARCH': arch,
                       'FLUTTER_ROOT': str(root), 'REVERIC_CODEMODE_CACHE': str(root / 'cache'),
                       'PATH': str(bin_dir) + os.pathsep + os.environ['PATH']}
                command = ['bash', str(root / 'tools/build_codemode_runtime.sh')]
                result = subprocess.run(command, env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((root / 'build.log').read_text(), '--macos-arch ' + arch + '\n')
                binaries = root / 'third/fjs/darwin/fjs/Binaries'
                shutil.rmtree(binaries)
                result = subprocess.run(command, env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((root / 'build.log').read_text().count('\n'), 1)
                self.assertEqual((binaries / 'fjs.xcframework.zip').read_text(), 'archive')

    def test_assembler_host_mode_does_not_require_ios_or_other_macos_dylibs(self):
        # Run the real assembler until its first native-tool call. With the old
        # all-Apple path it fails sooner because only one retained dylib exists.
        for arch, target in [('arm64', 'aarch64-apple-darwin'), ('x86_64', 'x86_64-apple-darwin')]:
            with self.subTest(arch=arch), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                target_dir = root / 'targets' / target
                target_dir.mkdir(parents=True)
                (target_dir / (target + '_libfjs.dylib')).write_bytes(b'native')
                workspace = root / 'workspace'
                workspace.mkdir()
                (workspace / 'pubspec.yaml').write_text('version: 3.3.1\n')
                bin_dir = root / 'bin'
                bin_dir.mkdir()
                native = bin_dir / 'install_name_tool'
                native.write_text('#!/bin/sh\necho "reached native assembly" >&2\nexit 91\n')
                native.chmod(0o755)
                env = {**os.environ, 'PATH': str(bin_dir) + os.pathsep + os.environ['PATH'],
                       'CARGOKIT_TARGET_OUTPUT_ROOT': str(root / 'targets'),
                       'CARGOKIT_OUTPUT_ROOT': str(root / 'output'),
                       'CARGOKIT_WORKSPACE_ROOT': str(workspace)}
                command = ['sh', str(ROOT / 'third/fjs/tool/assemble_fjs_xcframework.sh')]
                result = subprocess.run(command + ['--macos-arch', arch], env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 91, result.stderr)
                self.assertIn('reached native assembly', result.stderr)
                full = subprocess.run(command, env=env, capture_output=True, text=True)
                self.assertNotEqual(full.returncode, 0)
                self.assertIn('aarch64-apple-ios', full.stderr)

    def test_host_checker_rejects_wrong_platform_before_native_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            archive = Path(temporary) / 'fjs.zip'
            for identifier in ('ios-arm64', 'macos-x86_64'):
                with self.subTest(identifier=identifier):
                    with zipfile.ZipFile(archive, 'w') as output:
                        output.writestr('fjs.xcframework/Info.plist', plistlib.dumps({
                            'AvailableLibraries': [{'LibraryIdentifier': identifier,
                                'LibraryPath': 'fjs.framework', 'SupportedPlatform': 'macos',
                                'SupportedArchitectures': ['arm64']}]}))
                    result = subprocess.run(['sh', str(ROOT / 'third/fjs/tool/check_darwin_package_support.sh'),
                                             '--artifact', str(archive), '--macos-arch', 'arm64'],
                                            capture_output=True, text=True)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn('exactly the requested macOS architecture', result.stderr)


if __name__ == '__main__':
    unittest.main()
