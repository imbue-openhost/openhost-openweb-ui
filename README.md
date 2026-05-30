# openhost-openweb-ui

[Open WebUI](https://github.com/open-webui/open-webui) packaged for deployment on OpenHost. A startup wrapper (`openhost_start.sh`) adapts it to OpenHost's data, auth, and domain conventions.

## Deploying

In your OpenHost router dashboard, choose **Add App**, use this repository URL, and confirm. The app is served privately at `https://{app_name}.{zone_domain}` — no public paths are configured, so every request is gated to the compute-space owner.

## Authentication

Because OpenHost already authenticates the owner, Open WebUI runs in single-user mode (`WEBUI_AUTH=False`): the owner lands directly on the main page as the admin user, with no Open WebUI login.

To use Open WebUI's own multi-user auth instead, set `WEBUI_AUTH=True` in the app's environment.

## Upgrading Open WebUI

The image is pinned to a release tag in the `Dockerfile`. To upgrade, bump the tag.

## Data

- **Backed up** (`OPENHOST_APP_DATA_DIR`): database, settings, uploads, vector data, secret key.
- **Not backed up** (`OPENHOST_APP_TEMP_DIR`): the model cache (embedding/whisper/tiktoken), which is large and regenerable.

Inject model API keys as environment variables via your OpenHost app settings.

## Tests

End-to-end tests drive the real container behind a mock OpenHost router using the [openhost-app-test-harness](https://github.com/imbue-openhost/openhost-app-test-harness) and Playwright. Requires podman.

```bash
uv sync
uv run playwright install chromium
uv run pytest
```
