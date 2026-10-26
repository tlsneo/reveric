#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage: tool/build_fjs_xcframework.sh [--configuration Release] [--output PATH] [--zip-output PATH] [--macos-arch arm64|x86_64]

Builds a pinned CargoKit generation and copies its SwiftPM zip and checksum.
By default all five Apple targets are built. --macos-arch builds only the
specified macOS architecture, without installing any iOS Rust targets.
USAGE
}

CONFIGURATION=Release
OUTPUT_DIR=""
ZIP_OUTPUT=""
MACOS_ARCH=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --configuration)
      [ "$#" -ge 2 ] || {
        usage >&2
        exit 2
      }
      CONFIGURATION="$2"
      shift 2
      ;;
    --output)
      [ "$#" -ge 2 ] || {
        usage >&2
        exit 2
      }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --zip-output)
      [ "$#" -ge 2 ] || {
        usage >&2
        exit 2
      }
      ZIP_OUTPUT="$2"
      shift 2
      ;;
    --macos-arch)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      case "$2" in
        arm64|x86_64) MACOS_ARCH="$2" ;;
        *) usage >&2; exit 2 ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

[ "$CONFIGURATION" = Release ] || {
  echo "error: local precompiled generations support only --configuration Release" >&2
  exit 2
}

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
[ -n "$OUTPUT_DIR" ] || OUTPUT_DIR="$ROOT_DIR/darwin/fjs/Binaries"
case "$OUTPUT_DIR" in
  /*) ;;
  *) OUTPUT_DIR="$(pwd)/$OUTPUT_DIR" ;;
esac
[ -n "$ZIP_OUTPUT" ] || ZIP_OUTPUT="$OUTPUT_DIR/fjs.xcframework.zip"
case "$ZIP_OUTPUT" in
  /*) ;;
  *) ZIP_OUTPUT="$(pwd)/$ZIP_OUTPUT" ;;
esac

BUILD_ROOT="$ROOT_DIR/build/darwin-xcframework${MACOS_ARCH:+-macos-$MACOS_ARCH}"
GENERATION_ROOT="$BUILD_ROOT/generation"
RUST_TEMP_ROOT="$BUILD_ROOT/rust"
TOOL_TEMP_ROOT="$BUILD_ROOT/build_tool"

mkdir -p "$BUILD_ROOT" "$TOOL_TEMP_ROOT"
if [ -n "$MACOS_ARCH" ]; then
  case "$MACOS_ARCH" in
    arm64) RUST_TARGET=aarch64-apple-darwin ;;
    x86_64) RUST_TARGET=x86_64-apple-darwin ;;
  esac
  CARGOKIT_TOOL_TEMP_DIR="$TOOL_TEMP_ROOT" \
    sh "$ROOT_DIR/cargokit/run_build_tool.sh" build-precompiled-generation \
      --manifest-dir "$ROOT_DIR/libfjs" \
      --output-dir "$GENERATION_ROOT" \
      --temp-dir "$RUST_TEMP_ROOT" \
      --no-composites --target "$RUST_TARGET"
  mkdir -p "$GENERATION_ROOT/composites/swiftpm"
  CARGOKIT_TARGET_OUTPUT_ROOT="$GENERATION_ROOT/targets" \
    CARGOKIT_OUTPUT_ROOT="$GENERATION_ROOT/composites/swiftpm" \
    CARGOKIT_WORKSPACE_ROOT="$ROOT_DIR" \
    CARGOKIT_DART_EXECUTABLE="${FLUTTER_ROOT:?FLUTTER_ROOT is required}/bin/dart" \
    sh "$ROOT_DIR/tool/assemble_fjs_xcframework.sh" --macos-arch "$MACOS_ARCH"
else
  CARGOKIT_TOOL_TEMP_DIR="$TOOL_TEMP_ROOT" \
    sh "$ROOT_DIR/cargokit/run_build_tool.sh" build-precompiled-generation \
      --manifest-dir "$ROOT_DIR/libfjs" \
      --output-dir "$GENERATION_ROOT" \
      --temp-dir "$RUST_TEMP_ROOT" \
      --target aarch64-apple-ios \
      --target aarch64-apple-ios-sim \
      --target x86_64-apple-ios \
      --target aarch64-apple-darwin \
      --target x86_64-apple-darwin
fi

COMPOSITE_ROOT="$GENERATION_ROOT/composites/swiftpm"
SOURCE_ZIP="$COMPOSITE_ROOT/fjs.xcframework.zip"
SOURCE_CHECKSUM="$COMPOSITE_ROOT/fjs.xcframework.zip.checksum"
[ -f "$SOURCE_ZIP" ] || {
  echo "error: CargoKit generation did not produce $SOURCE_ZIP" >&2
  exit 1
}
[ -f "$SOURCE_CHECKSUM" ] || {
  echo "error: CargoKit generation did not produce $SOURCE_CHECKSUM" >&2
  exit 1
}

ZIP_OUTPUT_DIR="$(dirname -- "$ZIP_OUTPUT")"
mkdir -p "$ZIP_OUTPUT_DIR"
COPY_TEMP="$(mktemp -d "$ZIP_OUTPUT_DIR/.fjs-generation-copy.XXXXXX")"
cleanup() {
  rm -rf "$COPY_TEMP"
}
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

cp "$SOURCE_ZIP" "$COPY_TEMP/fjs.xcframework.zip"
cp "$SOURCE_CHECKSUM" "$COPY_TEMP/fjs.xcframework.zip.checksum"
cmp -s "$SOURCE_ZIP" "$COPY_TEMP/fjs.xcframework.zip" || {
  echo "error: copied composite zip differs from CargoKit output" >&2
  exit 1
}
cmp -s "$SOURCE_CHECKSUM" "$COPY_TEMP/fjs.xcframework.zip.checksum" || {
  echo "error: copied composite checksum differs from CargoKit output" >&2
  exit 1
}
mv -f "$COPY_TEMP/fjs.xcframework.zip" "$ZIP_OUTPUT"
mv -f "$COPY_TEMP/fjs.xcframework.zip.checksum" "$ZIP_OUTPUT.checksum"

echo "Created $ZIP_OUTPUT"
echo "Created $ZIP_OUTPUT.checksum"
