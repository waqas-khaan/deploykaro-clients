#!/usr/bin/env bash
set -Eeuo pipefail

: "${DEPLOY_TARGET:?DEPLOY_TARGET is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_ACTOR:?GITHUB_ACTOR is required}"
: "${GITHUB_RUN_NUMBER:?GITHUB_RUN_NUMBER is required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE_DIR="/home/alice/deploykaro-staging/fees"

ssh "$DEPLOY_TARGET" mkdir -p \
  "$REMOTE_DIR/routes" \
  "$REMOTE_DIR/resources/views" \
  "$REMOTE_DIR/tests/Feature"

rsync -az -e ssh "$ROOT/fees/app/routes/web.php" \
  "$DEPLOY_TARGET:$REMOTE_DIR/routes/web.php"

rsync -az -e ssh "$ROOT/fees/app/resources/views/payments.blade.php" \
  "$DEPLOY_TARGET:$REMOTE_DIR/resources/views/payments.blade.php"

rsync -az -e ssh "$ROOT/fees/app/tests/Feature/PaymentsPageTest.php" \
  "$DEPLOY_TARGET:$REMOTE_DIR/tests/Feature/PaymentsPageTest.php"

ssh "$DEPLOY_TARGET" sudo /usr/local/sbin/deploy-fees \
  "$GITHUB_SHA" "$GITHUB_ACTOR" "$GITHUB_RUN_NUMBER"
