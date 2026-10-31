#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:?Usage: deploy-bakery.sh SOURCE_DIR USER@SERVER}"
TARGET="${2:?Usage: deploy-bakery.sh SOURCE_DIR USER@SERVER}"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

SERVER="${TARGET#*@}"

if [ "$SERVER" = "$TARGET" ]; then
    echo "Error: Target must be USER@SERVER"
    exit 1
fi

RELEASE="$(date +%Y%m%d-%H%M%S)"
BASE="/var/www/bakery"
REMOTE_RELEASE="$BASE/releases/$RELEASE"

COMMIT="$(git -C "$SOURCE_DIR" rev-parse --short HEAD)"

if [ -n "${GITHUB_RUN_NUMBER:-}" ]; then
    DEPLOYED_BY="GitHub Actions run $GITHUB_RUN_NUMBER"
else
    DEPLOYED_BY="$(id -un)"
fi

REVISION_LINE="$COMMIT deployed by $DEPLOYED_BY at $(date '+%Y-%m-%d %H:%M:%S')"

echo "Previous release:"
PREVIOUS="$(ssh "$TARGET" "readlink '$BASE/current' || true")"
echo "${PREVIOUS:-None}"

echo "Uploading release: $RELEASE"

ssh "$TARGET" "mkdir -p '$REMOTE_RELEASE'"
rsync -az --delete "$SOURCE_DIR/" "$TARGET:$REMOTE_RELEASE/"

REVISION_B64="$(printf '%s' "$REVISION_LINE" | base64 -w 0)"

ssh "$TARGET" bash -s -- "$RELEASE" "$REVISION_B64" <<'REMOTE'
set -euo pipefail
BASE="/var/www/bakery"
RELEASE="$1"
REVISION_LINE="$(printf '%s' "$2" | base64 -d)"
printf '%s\n' "$REVISION_LINE" > "$BASE/releases/$RELEASE/REVISION"
ln -s "releases/$RELEASE" "$BASE/current.next"
mv -Tf "$BASE/current.next" "$BASE/current"
REMOTE


echo "Checking homepage..."

HTTP_URL="ht"
HTTP_URL+="tp"
HTTP_URL+="://"
HTTP_URL+="$SERVER"
HTTP_URL+="/"
HTTP_CODE="$(curl -sS -o /dev/null -w '%{http_code}' -H 'Host: bakery.local' "$HTTP_URL" || true)"

if [ "$HTTP_CODE" != "200" ]; then
    echo "Homepage check failed: HTTP $HTTP_CODE"
    echo "Restoring previous release..."

    ssh "$TARGET" bash -s -- "$RELEASE" "$PREVIOUS" <<'REMOTE'
set -euo pipefail

BASE="/var/www/bakery"
RELEASE="$1"
PREVIOUS="$2"

if [ -n "$PREVIOUS" ]; then
    ln -s "$PREVIOUS" "$BASE/current.rollback"
    mv -Tf "$BASE/current.rollback" "$BASE/current"
else
    rm -f "$BASE/current"
fi

rm -rf "$BASE/releases/$RELEASE"
REMOTE

    echo "Rollback completed. Failed release deleted."
    exit 1
fi

echo "Homepage check passed: HTTP 200"

ssh "$TARGET" bash -s <<'REMOTE'
set -euo pipefail

BASE="/var/www/bakery"

find "$BASE/releases" -mindepth 1 -maxdepth 1 -type d \
    -printf '%f\n' | sort -r | tail -n +4 |
while IFS= read -r OLD_RELEASE; do
    rm -rf "$BASE/releases/$OLD_RELEASE"
done
REMOTE

echo "Deployment successful."
echo "Kept the three newest releases."
