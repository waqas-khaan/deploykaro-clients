cd ~/deploykaro-clients

cat > scripts/with-deploy-key.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOY_SSH_KEY:?Missing DEPLOY_SSH_KEY secret}"
: "${DEPLOY_KNOWN_HOSTS:?Missing DEPLOY_KNOWN_HOSTS secret}"
: "${DEPLOY_TARGET:?Missing DEPLOY_TARGET variable}"

TEMP_DIR="$(mktemp -d)"

eval "$(ssh-agent -s)" >/dev/null

cleanup() {
    ssh-agent -k >/dev/null 2>&1 || true
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TEMP_DIR/.ssh"
chmod 700 "$TEMP_DIR/.ssh"

printf '%s\n' "$DEPLOY_SSH_KEY" > "$TEMP_DIR/id_deploy"
chmod 600 "$TEMP_DIR/id_deploy"

printf '%s\n' "$DEPLOY_KNOWN_HOSTS" > "$TEMP_DIR/.ssh/known_hosts"
chmod 600 "$TEMP_DIR/.ssh/known_hosts"

export HOME="$TEMP_DIR"

ssh-add "$TEMP_DIR/id_deploy"

SSH_OPTIONS=(
    -o BatchMode=yes
    -o StrictHostKeyChecking=yes
    -o UserKnownHostsFile="$TEMP_DIR/.ssh/known_hosts"
    -o GlobalKnownHostsFile=/dev/null
    -o ConnectTimeout=10
)

echo "Checking SSH known_hosts entry..."
ssh-keygen -F 16.176.178.205 \
    -f "$TEMP_DIR/.ssh/known_hosts"

echo "Testing SSH connection to $DEPLOY_TARGET..."

ssh "${SSH_OPTIONS[@]}" "$DEPLOY_TARGET" \
    "echo SSH_CONNECTION_OK"

echo "SSH verification successful."
echo "Starting deployment..."

"$@"
EOF

chmod +x scripts/with-deploy-key.sh
