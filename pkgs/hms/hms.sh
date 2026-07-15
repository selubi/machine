#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

# 1. Raise if no argument is passed at all
if [[ -z "$TARGET" ]]; then
    echo "❌ Error: No target specified!"
    echo "Usage: hms <flake-path>#<attribute>  (e.g., hms .#myattr)"
    exit 1
fi

# 2. Raise if they forgot the '#' separator entirely
if [[ "$TARGET" != *#* ]]; then
    echo "❌ Error: Target must specify an output attribute using '#' (e.g., .#myattr)"
    exit 1
fi

# Extract the flake path and the output attribute name
FLAKE_PATH="${TARGET%%#*}"
ATTRIBUTE_NAME="${TARGET##*#}"

# 3. Enforce that the flake path is not empty
if [[ -z "$FLAKE_PATH" ]]; then
    echo "❌ Error: Missing flake path!"
    echo "You must provide a path before the '#' (e.g., use 'hms .#myattr' instead of 'hms #myattr')"
    exit 1
fi

# 4. Enforce that the output attribute is not empty
if [[ -z "$ATTRIBUTE_NAME" ]]; then
    echo "❌ Error: Missing output attribute name!"
    echo "You must provide an attribute after the '#' (e.g., 'hms .#myattr')"
    exit 1
fi

BUILD_TARGET="${FLAKE_PATH}#homeConfigurations.${ATTRIBUTE_NAME}.activationPackage"

# Set up a trap to clean up the temporary symlink on exit
TEMP_LINK=$(mktemp -t hm-build-XXX)
rm "$TEMP_LINK" # Remove the temp file so nix can write it as a symlink
cleanup() {
    rm -f "$TEMP_LINK"
}
trap cleanup EXIT

echo "Building target: $BUILD_TARGET..."

# 5. Build the target in isolation
if ! nix build "$BUILD_TARGET" --out-link "$TEMP_LINK" --no-write-lock-file; then
    echo "❌ Build failed!"
    exit 1
fi

# 6. Use dix to show the lightning-fast Rust-powered diff
echo "========================================================================"
echo "                           GENERATION DIFF"
echo "========================================================================"
dix ~/.local/state/nix/profiles/home-manager "$TEMP_LINK"
echo "========================================================================"

# 7. Interactive prompt
read -r -p "Do you want to switch to this generation? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        echo "Applying generation..."
        "$TEMP_LINK/activate"
        ;;
    *)
        echo "Aborted. No changes were made."
        ;;
esac