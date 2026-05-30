FROM ghcr.io/open-webui/open-webui:v0.9.5

# mitmproxy fronts the Bifrost gateway's service interface as a local OpenAI
# endpoint (see openhost_bifrost_proxy.py). Install it in its own venv so its
# deps can't clash with Open WebUI's pinned ones.
RUN python3 -m venv /opt/mitmproxy \
    && /opt/mitmproxy/bin/pip install --no-cache-dir mitmproxy

COPY openhost_bifrost_proxy.py /app/openhost_bifrost_proxy.py
COPY openhost_start.sh /app/openhost_start.sh
RUN chmod +x /app/openhost_start.sh

EXPOSE 8080

CMD ["/app/openhost_start.sh"]
