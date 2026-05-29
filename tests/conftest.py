"""Shared pytest fixtures.

Spins up the real Open WebUI container behind the mock OpenHost router (which
injects ``X-OpenHost-Is-Owner: true`` on every request, exactly like the real
router does for the authenticated compute-space owner), and provides a
Playwright browser pointed at it.
"""

import tempfile
from collections.abc import Iterator
from pathlib import Path

import pytest
from openhost_test_harness import OpenhostStack
from playwright.sync_api import Browser, Page, sync_playwright

REPO_ROOT = Path(__file__).resolve().parent.parent

# The harness bind-mounts a tempfile.mkdtemp() data dir into the app container.
# On macOS the podman VM only shares /Users, /private and /var/folders, but a
# sandboxed TMPDIR (e.g. /tmp/claude-501) is not shared, so the mount fails with
# "statfs ... no such file or directory". Pin the harness temp dir under $HOME
# (shared as /Users) so the mount works regardless of the ambient TMPDIR.
_HARNESS_TMP = Path.home() / ".cache" / "openhost-test-tmp"
_HARNESS_TMP.mkdir(parents=True, exist_ok=True)
tempfile.tempdir = str(_HARNESS_TMP)

# Router identity env that openhost_start.sh reads. The harness provides the
# data/temp mount vars (OPENHOST_APP_DATA_DIR / OPENHOST_APP_TEMP_DIR) from the
# manifest; these are the remaining vars the real router would inject.
APP_ENV = {
    "OPENHOST_APP_NAME": "openweb-ui",
    "OPENHOST_ZONE_DOMAIN": "localhost",
}


@pytest.fixture(scope="session")
def stack() -> Iterator[OpenhostStack]:
    # Open WebUI's first boot runs DB migrations and downloads embedding models
    # from HuggingFace before it binds, so it needs a generous readiness window.
    with OpenhostStack(app_dir=REPO_ROOT, extra_env=APP_ENV, readiness_timeout=300) as s:
        yield s


@pytest.fixture(scope="session")
def browser() -> Iterator[Browser]:
    with sync_playwright() as p:
        b = p.chromium.launch()
        try:
            yield b
        finally:
            b.close()


@pytest.fixture
def page(browser: Browser) -> Iterator[Page]:
    context = browser.new_context()
    pg = context.new_page()
    try:
        yield pg
    finally:
        context.close()
