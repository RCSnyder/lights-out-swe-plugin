#!/usr/bin/env bash
# init.sh — bootstrap a new project repo for the lo-swe plugin.
#
# Copies the templates in ./templates/ into a target directory (default: $PWD).
# Refuses to overwrite an existing .github/copilot-instructions.md so re-running
# is safe. Other existing files are skipped (no-clobber) and reported.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
TARGET_DIR="${1:-$PWD}"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "ERROR: templates directory not found at $TEMPLATES_DIR" >&2
  exit 2
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: target directory does not exist: $TARGET_DIR" >&2
  exit 2
fi

# Refuse if the harness is already installed.
if [[ -f "$TARGET_DIR/.github/copilot-instructions.md" ]]; then
  echo "REFUSED: $TARGET_DIR/.github/copilot-instructions.md already exists." >&2
  echo "Delete it (and review the rest of the harness) before re-running /lo-swe:init." >&2
  exit 1
fi

written=()
skipped=()

# Walk every file in templates/ (including hidden ones) and copy if absent.
while IFS= read -r -d '' src; do
  rel="${src#$TEMPLATES_DIR/}"
  dest="$TARGET_DIR/$rel"
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  if [[ -e "$dest" ]]; then
    skipped+=("$rel")
  else
    cp "$src" "$dest"
    written+=("$rel")
  fi
done < <(find "$TEMPLATES_DIR" -type f -print0)

echo "lo-swe init complete in: $TARGET_DIR"
echo ""
echo "Wrote ${#written[@]} file(s):"
for f in "${written[@]}"; do
  echo "  + $f"
done

if (( ${#skipped[@]} > 0 )); then
  echo ""
  echo "Skipped ${#skipped[@]} existing file(s) (left untouched):"
  for f in "${skipped[@]}"; do
    echo "  = $f"
  done
fi

echo ""
echo "Next steps:"
echo "  1. Open $TARGET_DIR in VS Code"
echo "  2. Edit preferences.md to match your stack and deploy targets"
echo "  3. (Optional) Drop reference materials in docs/input/"
echo "  4. In Copilot agent mode, say: build me <description>"
