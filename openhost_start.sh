#!/usr/bin/env bash
set -euo pipefail

# Adapts Open WebUI to OpenHost conventions, then hands off to the image's
# start.sh. Expects the standard OpenHost environment to be present.

: "${OPENHOST_APP_DATA_DIR:?}"
: "${OPENHOST_APP_TEMP_DIR:?}"
: "${OPENHOST_APP_NAME:?}"
: "${OPENHOST_ZONE_DOMAIN:?}"

# Persistent, backed-up app state.
export DATA_DIR="$OPENHOST_APP_DATA_DIR"
mkdir -p "$DATA_DIR"

# Model cache: large and regenerable, so keep it in the non-backed-up temp dir.
# Open WebUI hardcodes CACHE_DIR to "$DATA_DIR/cache", so redirect that path to
# the temp dir via a symlink. The temp dir persists across reloads.
CACHE_DIR="$OPENHOST_APP_TEMP_DIR/cache"
mkdir -p "$CACHE_DIR"
# Best-effort seed from the models bundled in the image: fills anything missing
# (first boot, or a wiped cache) without clobbering on-demand downloads or
# failing the boot.
cp -an /app/backend/data/cache/. "$CACHE_DIR/" 2>/dev/null || true
rm -rf "$DATA_DIR/cache"
ln -s "$CACHE_DIR" "$DATA_DIR/cache"

# Persist the session-signing key so logins survive restarts.
export WEBUI_SECRET_KEY_FILE="$DATA_DIR/.webui_secret_key"

# Bypass Open WebUI's own auth; the OpenHost router already gates to the owner.
export WEBUI_AUTH="False"

# Public URL for the app's OpenHost zone.
export WEBUI_URL="https://$OPENHOST_APP_NAME.$OPENHOST_ZONE_DOMAIN"

cd /app/backend
exec bash /app/backend/start.sh "$@"
