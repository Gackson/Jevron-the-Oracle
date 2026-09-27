#!/bin/bash
# Development certificates only. Trust the CA in a dedicated simulator, never the host keychain.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .local
umask 077
if [[ -f .local/localhost.crt && -f .local/localhost.key && -f .local/ca.crt ]]; then
  echo 'Existing certificates in server/.local; retained.'
  exit 0
fi
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 7 \
  -keyout .local/ca.key -out .local/ca.crt -subj '/CN=JEV Local Development CA' \
  -addext 'basicConstraints=critical,CA:TRUE' -addext 'keyUsage=critical,keyCertSign,cRLSign' 2>/dev/null
openssl req -newkey rsa:2048 -nodes -sha256 -keyout .local/localhost.key \
  -out .local/localhost.csr -subj '/CN=localhost' 2>/dev/null
cat > .local/localhost.ext <<'EOF'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=DNS:localhost,IP:127.0.0.1
EOF
openssl x509 -req -in .local/localhost.csr -CA .local/ca.crt -CAkey .local/ca.key \
  -CAcreateserial -out .local/localhost.crt -days 7 -sha256 -extfile .local/localhost.ext 2>/dev/null
echo 'Created 7-day local development certificates in server/.local.'
