#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DATA_DIR="/app/backend/data"
PERSIST_DIR="${OPENHOST_APP_DATA_DIR:-$UPSTREAM_DATA_DIR}"
INIT_MARKER="${PERSIST_DIR}/.openhost_initialized"

mkdir -p "$PERSIST_DIR"

if [ "$PERSIST_DIR" != "$UPSTREAM_DATA_DIR" ]; then
    if [ ! -f "$INIT_MARKER" ]; then
        mkdir -p "$UPSTREAM_DATA_DIR"
        cp -a "$UPSTREAM_DATA_DIR/." "$PERSIST_DIR/" 2>/dev/null || true
        touch "$INIT_MARKER"
    fi

    rm -rf "$UPSTREAM_DATA_DIR"
    ln -s "$PERSIST_DIR" "$UPSTREAM_DATA_DIR"
fi

if [ -z "${WEBUI_SECRET_KEY:-}" ] && [ -z "${WEBUI_JWT_SECRET_KEY:-}" ]; then
    export WEBUI_SECRET_KEY_FILE="${PERSIST_DIR}/.webui_secret_key"
fi

if [ -n "${OPENHOST_ZONE_DOMAIN:-}" ] && [ -z "${WEBUI_URL:-}" ]; then
    APP_SUBDOMAIN="${OPENHOST_APP_NAME:-openweb-ui}"

    case "$OPENHOST_ZONE_DOMAIN" in
        lvh.me|*.lvh.me|localhost|*.localhost)
            ROUTER_PORT=""
            if [ -n "${OPENHOST_ROUTER_URL:-}" ]; then
                ROUTER_PORT=$(printf "%s" "$OPENHOST_ROUTER_URL" | sed -n 's/.*:\([0-9]*\)$/\1/p')
            fi
            export WEBUI_URL="http://${APP_SUBDOMAIN}.${OPENHOST_ZONE_DOMAIN}${ROUTER_PORT:+:$ROUTER_PORT}"
            ;;
        *)
            export WEBUI_URL="https://${APP_SUBDOMAIN}.${OPENHOST_ZONE_DOMAIN}"
            ;;
    esac
fi

cd /app/backend
exec bash /app/backend/start.sh "$@"
