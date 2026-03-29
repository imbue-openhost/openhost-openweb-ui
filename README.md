# openhost-openweb-ui

Open WebUI packaged for deployment on OpenHost.

## What this repo provides

- `openhost.toml` manifest for OpenHost deployment
- Docker image based on `ghcr.io/open-webui/open-webui:main`
- Startup wrapper that adapts Open WebUI to OpenHost data and domain conventions

## OpenHost behavior

On startup, `openhost_start.sh`:

1. Uses `OPENHOST_APP_DATA_DIR` for persistent app state.
2. Copies initial bundled data into persistent storage on first boot.
3. Persists the WebUI secret key in app data unless explicitly provided.
4. Sets `WEBUI_URL` from `OPENHOST_APP_NAME` and `OPENHOST_ZONE_DOMAIN` (uses `http` for local `lvh.me`/`localhost` zones, `https` otherwise).

By default, no `routing.public_paths` are configured, so the app remains private behind OpenHost auth.

## Deploying

1. In your OpenHost router dashboard, choose **Add App**.
2. Use this repository URL.
3. Confirm deploy.

The app is served at:

- `https://{app_name}.{zone_domain}`

## Data

Persistent data is stored in `OPENHOST_APP_DATA_DIR` and includes:

- Open WebUI database and settings
- uploaded files and vector data
- `.webui_secret_key`

## Notes

- Open WebUI still manages its own internal user accounts and model provider configuration.
- If you want model API keys available at runtime, inject them as environment variables through your OpenHost secrets/app settings flow.
