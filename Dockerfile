FROM ghcr.io/open-webui/open-webui:main

COPY openhost_start.sh /app/openhost_start.sh
RUN chmod +x /app/openhost_start.sh

EXPOSE 8080

CMD ["/app/openhost_start.sh"]
