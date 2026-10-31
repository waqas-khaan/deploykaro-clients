#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOY_SSH_KEY:?Missing DEPLOY_SSH_KEY secret}"
: "${DEPLOY_KNOWN_HOSTS:?Missing DEPLOY_KNOWN_HOSTS secret}"
: "${DEPLOY_TARGET:?Missing DEPLOY_TARGET variable}"

TEMP_DIR="$(mktemp -d)"
ORIGINAL_HOME="$HOME"

eval "$(ssh-agent -s)" >/dev/null

cleanup() {
    ssh-agent -k >/dev/null 2>&1 || true
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TEMP_DIR/.ssh" "$TEMP_DIR/bin"
chmod 700 "$TEMP_DIR/.ssh"

printf '%s\n' "$DEPLOY_SSH_KEY" > "$TEMP_DIR/id_deploy"
printf '%s\n' "$DEPLOY_KNOWN_HOSTS" > "$TEMP_DIR/.ssh/known_hosts"
chmod 600 "$TEMP_DIR/id_deploy" "$TEMP_DIR/.ssh/known_hosts"

ssh-add "$TEMP_DIR/id_deploy"

cat > "$TEMP_DIR/bin/ssh" <<'SSH_WRAPPER'
#!/usr/bin/env bash
exec /usr/bin/ssh \
  -o BatchMode=yes \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile="$DEPLOY_SSH_KNOWN_HOSTS" \
  -o GlobalKnownHostsFile=/dev/null \
  -o ConnectTimeout=10 \
  "$@"
SSH_WRAPPER

chmod 700 "$TEMP_DIR/bin/ssh"

export DEPLOY_SSH_KNOWN_HOSTS="$TEMP_DIR/.ssh/known_hosts"
export PATH="$TEMP_DIR/bin:$PATH"

echo "Checking SSH host key..."
ssh-keygen -F 16.176.178.205 -f "$DEPLOY_SSH_KNOWN_HOSTS"

echo "Testing SSH connection..."
ssh "$DEPLOY_TARGET" "echo SSH_CONNECTION_OK"

echo "Starting deployment..."
"$@"
