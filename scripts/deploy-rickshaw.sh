#!/usr/bin/env bash
set -Eeuo pipefail

: "${DEPLOY_TARGET:?DEPLOY_TARGET is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_ACTOR:?GITHUB_ACTOR is required}"
: "${GITHUB_RUN_NUMBER:?GITHUB_RUN_NUMBER is required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE_DIR="/home/alice/deploykaro-staging/rickshaw/v2"

ssh "$DEPLOY_TARGET" mkdir -p "$REMOTE_DIR"

rsync -az -e ssh \
  "$ROOT/rickshaw/v2/package.json" \
  "$ROOT/rickshaw/v2/package-lock.json" \
  "$ROOT/rickshaw/v2/server.js" \
  "$DEPLOY_TARGET:$REMOTE_DIR/"

ssh "$DEPLOY_TARGET" sudo /usr/local/sbin/deploy-rickshaw \
  "$GITHUB_SHA" "$GITHUB_ACTOR" "$GITHUB_RUN_NUMBER"
