FROM ghcr.io/open-webui/open-webui:v0.9.5

# mitmproxy fronts the Bifrost gateway's service interface as a local OpenAI
# endpoint (see openhost_bifrost_proxy.py). Use the standalone binary so it
# doesn't touch Open WebUI's Python env.
RUN curl -fsSL https://downloads.mitmproxy.org/12.2.3/mitmproxy-12.2.3-linux-x86_64.tar.gz \
    | tar -xz -C /usr/local/bin mitmdump

COPY openhost_bifrost_proxy.py /app/openhost_bifrost_proxy.py
COPY openhost_start.sh /app/openhost_start.sh
RUN chmod +x /app/openhost_start.sh

EXPOSE 8080

CMD ["/app/openhost_start.sh"]
