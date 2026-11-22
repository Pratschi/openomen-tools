#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:" >&2
  cat >&2 <<EOF
Usage:
  $0 [--clean] CLI_X.X.X
  $0 [--clean] --local FILE --version VERSION

Options:
  --clean          Remove the package directory before creating it
  --local FILE     Package a local binary instead of downloading a release
  --version VERSION
                   Set the Debian package version (required with --local)
EOF
}

CLEAN=false
LOCAL_FILE=""
VERSION=""

while (($#)); do
  case "$1" in
    --clean)
      CLEAN=true
      shift
      ;;
    --local)
      if (($# < 2)); then
        echo "[FAIL] --local requires a file path." >&2
        usage
        exit 2
      fi
      LOCAL_FILE="$2"
      shift 2
      ;;
    --version)
      if (($# < 2)); then
        echo "[FAIL] --version requires a value." >&2
        usage
        exit 2
      fi
      VERSION="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$VERSION" ]]; then
        echo "[FAIL] Unexpected argument: '$1'" >&2
        usage
        exit 2
      fi
      VERSION="$1"
      shift
      ;;
  esac
done

if [[ -n "$LOCAL_FILE" ]]; then
  if [[ -z "$VERSION" ]]; then
    echo "[FAIL] --version is required with --local." >&2
    usage
    exit 2
  fi
  if [[ ! -f "$LOCAL_FILE" || ! -s "$LOCAL_FILE" ]]; then
    echo "[FAIL] Local file is missing or empty: '$LOCAL_FILE'" >&2
    exit 1
  fi
  SOURCE_FILE="$LOCAL_FILE"
else
  if [[ ! "$VERSION" =~ ^CLI_([0-9]+(\.[0-9]+)*)$ ]]; then
    echo "[FAIL] Expected a release tag like CLI_X.X.X, or use --local FILE --version VERSION." >&2
    exit 2
  fi

  TAG="$VERSION"
  VERSION="${TAG#CLI_}"
  URL="https://github.com/openomen/openomen/releases/download/${TAG}/openomen"
  TMP_BIN="$(mktemp)"
  trap 'rm -f "$TMP_BIN"' EXIT

  echo "[INFO] Downloading $URL ..."
  if ! curl --fail --location --silent --show-error "$URL" --output "$TMP_BIN"; then
    echo "[FAIL] Could not download $TAG's release binary." >&2
    exit 1
  fi
  if [[ ! -s "$TMP_BIN" ]]; then
    echo "[FAIL] Downloaded file is empty." >&2
    exit 1
  fi
  SOURCE_FILE="$TMP_BIN"
fi

# Restrict the version to characters accepted in Debian package versions.
if [[ ! "$VERSION" =~ ^[0-9][A-Za-z0-9.+:~\-]*$ ]]; then
  echo "[FAIL] Invalid package version: '$VERSION'." >&2
  exit 2
fi

PKG_DIR="./CLI_${VERSION}"
DEB_FILE="./openomen_${VERSION}_amd64.deb"

mkdir -p "$PKG_DIR/DEBIAN" "$PKG_DIR/usr/local/bin"
install -m 755 "$SOURCE_FILE" "$PKG_DIR/usr/local/bin/openomen"

cat > "$PKG_DIR/DEBIAN/control" <<EOF
Package: openomen
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: audixdev <audixdev@gmail.com>
Description: Unofficial driver and daemon for HP OMEN hardware on Linux.
EOF

dpkg-deb --build "$PKG_DIR" "$DEB_FILE"

if [[ "$CLEAN" == true ]]; then
  echo "[INFO] Cleaning..."
  rm -rf -- "$PKG_DIR"
fi

echo "[DONE] Created Debian Package: $DEB_FILE"
