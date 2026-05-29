# openhost-openweb-ui

Open WebUI packaged for deployment on OpenHost.

## What this repo provides

- `openhost.toml` manifest for OpenHost deployment
- Docker image pinned to a specific Open WebUI release (`ghcr.io/open-webui/open-webui`)
- Startup wrapper that adapts Open WebUI to OpenHost data, auth, and domain conventions

## OpenHost behavior

On startup, `openhost_start.sh`:

1. Points Open WebUI's `DATA_DIR` at `OPENHOST_APP_DATA_DIR` for persistent, backed-up app state.
2. Redirects Open WebUI's model cache out of the backed-up data dir into `OPENHOST_APP_TEMP_DIR` (not backed up), best-effort seeded from the models bundled in the image. It persists across reloads.
3. Persists the WebUI secret key in app data.
4. Bypasses Open WebUI's own login for the OpenHost owner (see below).
5. Sets `WEBUI_URL` to `https://{OPENHOST_APP_NAME}.{OPENHOST_ZONE_DOMAIN}`.

The script expects the standard OpenHost environment and exits if a required variable (`OPENHOST_APP_DATA_DIR`, `OPENHOST_APP_TEMP_DIR`, `OPENHOST_APP_NAME`, `OPENHOST_ZONE_DOMAIN`) is missing.

By default, no `routing.public_paths` are configured, so the app remains private behind OpenHost auth.

## Authentication

OpenHost already gates every request to the authenticated compute-space owner, so this deployment runs Open WebUI in single-user mode (`WEBUI_AUTH=False`). The owner lands directly on the main page instead of Open WebUI's onboarding/login wall, and is treated as the admin user.

To run Open WebUI's own multi-user auth instead, set `WEBUI_AUTH=True` (or `WEBUI_AUTH=true`) in the app's environment — the startup wrapper respects an explicit value.

## Deploying

1. In your OpenHost router dashboard, choose **Add App**.
2. Use this repository URL.
3. Confirm deploy.

The app is served at:

- `https://{app_name}.{zone_domain}`

## Data

Persistent, backed-up data is stored in `OPENHOST_APP_DATA_DIR` and includes:

- Open WebUI database and settings
- uploaded files and vector data
- `.webui_secret_key`

The model cache (embedding / whisper / tiktoken models — large and fully regenerable) lives in `OPENHOST_APP_TEMP_DIR` and is **not** backed up.

## Notes

- If you want model API keys available at runtime, inject them as environment variables through your OpenHost secrets/app settings flow.

## Tests

End-to-end tests drive the real container behind a mock OpenHost router using the
[openhost-app-test-harness](https://github.com/imbue-openhost/openhost-app-test-harness),
[uv](https://docs.astral.sh/uv/), and Playwright. They verify that on first boot
the owner lands on the main page (auth bypassed) and that the model cache stays
out of the backed-up data dir. Requires podman.

```bash
uv sync
uv run playwright install chromium
uv run pytest
```
