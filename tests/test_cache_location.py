"""The large, regenerable model cache must not land in OpenHost's backed-up
persistent app-data dir.

Open WebUI hardcodes its cache to ``$DATA_DIR/cache``; openhost_start.sh
redirects that path (via a symlink) to the temp dir (OPENHOST_APP_TEMP_DIR),
which is not part of the backed-up app_data mount. So here the persistent dir
should contain a *symlink* named ``cache`` pointing outside the mount, never the
cache data itself.
"""

from openhost_test_harness import OpenhostStack


def test_model_cache_not_in_persistent_data(stack: OpenhostStack) -> None:
    # Touch the app so it initializes its data dir, then inspect the host mount.
    assert stack.url  # session fixture is up

    data_dir = stack.data_dir
    cache = data_dir / "cache"

    # Real user data should be here...
    assert (data_dir / "webui.db").exists(), "expected Open WebUI db in persistent data dir"

    # ...but the cache must not be a real directory of model files in the mount.
    if cache.exists() or cache.is_symlink():
        assert cache.is_symlink(), f"cache is a real directory inside backed-up data: {cache}"

    # The bundled models (hundreds of MB) must not have been copied in here.
    for model_dir in ("embedding", "whisper", "tiktoken"):
        target = cache / model_dir
        assert not target.exists(), f"regenerable model cache leaked into persistent data: {target}"
