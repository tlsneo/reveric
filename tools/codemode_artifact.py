#!/usr/bin/env python3
"""Bind ignored FJS archives to source, targets and installed build tools."""
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BINARIES = ROOT / 'third/fjs/darwin/fjs/Binaries'
ARCHIVE = BINARIES / 'fjs.xcframework.zip'
RECORD = BINARIES / 'reveric-build.json'
RUST = '1.97.1'


def macos_arch():
    machine = platform.machine()
    if machine not in ('arm64', 'x86_64'):
        raise SystemExit('Unsupported macOS architecture: ' + machine)
    return machine


def macos_target():
    return {'arm64': 'aarch64-apple-darwin',
            'x86_64': 'x86_64-apple-darwin'}[macos_arch()]


def run(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def identity():
    paths = {name for name in run('git', 'ls-files', '--cached', '--others',
                                 '--exclude-standard', 'third/fjs').splitlines()
             if (ROOT / name).is_file()}
    paths.update(['cargokit_options.yaml', 'tools/build_codemode_runtime.sh',
                  'tools/codemode_artifact.py'])
    inputs = {name: digest(ROOT / name) for name in sorted(paths)}
    # Flutter only hosts the CargoKit build tool; dart-sys ships its own Dart API
    # headers, so the SDK revision does not reach the native archive.
    tools = {'rust': run('rustc', '+' + RUST, '-Vv'),
             'host': platform.system(), 'architecture': platform.machine()}
    if platform.system() == 'Darwin':
        tools.update(targets=[macos_target()],
                     xcode=run('xcodebuild', '-version'),
                     macosx=run('xcrun', '--sdk', 'macosx', '--show-sdk-version'))
    value = {'inputs': inputs, 'toolchain': tools}
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest(), value


def verify(key):
    if not RECORD.is_file() or not ARCHIVE.is_file():
        return False
    record = json.loads(RECORD.read_text())
    sidecar = ARCHIVE.with_suffix('.zip.checksum')
    if not sidecar.is_file():
        return False
    checksum = sidecar.read_text().strip()
    return record['key'] == key and record['archive_sha256'] == digest(ARCHIVE) == checksum


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else 'key'
    if command == 'arch':
        print(macos_arch())
        return
    key, value = identity()
    if command == 'key':
        print('fjs-' + key)
    elif command == 'verify':
        if not verify(key):
            raise SystemExit('FJS archive missing or source/toolchain/checksum mismatch')
        print('Verified patched archive: ' + digest(ARCHIVE))
    elif command == 'record':
        if len(sys.argv) != 3 or sys.argv[2] != 'fjs-' + key:
            raise SystemExit('Source/toolchain changed during native build; rebuild before recording')
        checksum = ARCHIVE.with_suffix('.zip.checksum').read_text().strip()
        if digest(ARCHIVE) != checksum:
            raise SystemExit('FJS generation checksum mismatch')
        generation = ROOT / ('third/fjs/build/darwin-xcframework-macos-' + macos_arch()) / 'generation/manifest.json'
        # CargoKit writes its own recipe/assets manifest alongside the generation.
        candidates = list(generation.parent.glob('*.json'))
        manifest = next((p for p in candidates if json.loads(p.read_text()).get('scope') == 'cargokit-local-precompiled-generation'), None)
        if manifest is None:
            raise SystemExit('CargoKit generation provenance missing')
        provenance = json.loads(manifest.read_text())
        if provenance['recipe']['rust_toolchain'] != RUST:
            raise SystemExit('CargoKit generation used a different Rust toolchain')
        target = macos_target()
        expected_assets = {target + '_libfjs.a', target + '_libfjs.dylib'}
        if {a['name'] for a in provenance['assets']} != expected_assets:
            raise SystemExit('Local generation must contain only the requested macOS target')
        for asset in provenance['assets']:
            if digest(generation.parent / asset['path']) != asset['sha256']:
                raise SystemExit('Retained target differs from local generation')
        assembled = generation.parent / 'composites/swiftpm' / ARCHIVE.name
        if digest(assembled) != checksum:
            raise SystemExit('Archive differs from local macOS assembly')
        RECORD.write_text(json.dumps({'key': key, 'archive_sha256': checksum,
                                      'source': value, 'generation': provenance}, indent=2) + '\n')
        print('Recorded patched archive: ' + checksum)
    elif command == 'verify-app':
        if not verify(key):
            raise SystemExit('Verify/build archive before checking app')
        app = Path(sys.argv[2])
        binary = app / 'Contents/Frameworks/fjs.framework/fjs'
        with tempfile.TemporaryDirectory(prefix='codemode-artifact-') as temporary:
            with zipfile.ZipFile(ARCHIVE) as archive:
                member = 'fjs.xcframework/macos-' + macos_arch() + '/fjs.framework/Versions/A/fjs'
                reference = archive.extract(member, temporary)
            def uuids(path):
                return {tuple(line.split()[1:3]) for line in run('dwarfdump', '--uuid', str(path)).splitlines()}
            if not uuids(binary) or not uuids(binary).issubset(uuids(reference)):
                raise SystemExit('Packaged FJS UUIDs differ from patched source archive')
        print('Packaged FJS UUIDs match patched archive: ' + str(binary))
    else:
        raise SystemExit('usage: codemode_artifact.py arch|key|verify|record|verify-app APP')


if __name__ == '__main__':
    main()
