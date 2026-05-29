# Pinned to the v0.9.5 release by multi-arch index digest (amd64 + arm64) for
# reproducible builds. To upgrade: bump the tag and refresh the digest with
#   docker buildx imagetools inspect ghcr.io/open-webui/open-webui:<tag>
FROM ghcr.io/open-webui/open-webui:v0.9.5@sha256:e045bde3b004cc7f8c319412345eb56c87ea6ac57031534a31ca37ad5424beb3

COPY openhost_start.sh /app/openhost_start.sh
RUN chmod +x /app/openhost_start.sh

EXPOSE 8080

CMD ["/app/openhost_start.sh"]
