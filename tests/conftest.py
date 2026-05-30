"""Shared pytest fixtures.

Spins up the real Open WebUI container behind the mock OpenHost router (which
injects ``X-OpenHost-Is-Owner: true`` on every request, exactly like the real
router does for the authenticated compute-space owner), and provides a
Playwright browser pointed at it.
"""

from collections.abc import Iterator

import pytest
from openhost_test_harness import OpenhostStack
from playwright.sync_api import Browser, Page, sync_playwright


@pytest.fixture(scope="session")
def stack() -> Iterator[OpenhostStack]:
    # Open WebUI's first boot runs DB migrations and downloads embedding models
    # from HuggingFace before it binds, so it needs a generous readiness window.
    with OpenhostStack(readiness_timeout=300) as s:
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
