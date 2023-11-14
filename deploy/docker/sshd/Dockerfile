FROM debian:11

COPY install.sh entrypoint.sh /
RUN bash /install.sh && \
    rm -rf /install.sh && \
    chmod 755 /entrypoint.sh

EXPOSE 22

CMD ["/entrypoint.sh"]

