FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Répertoire chroot par défaut de vsftpd (secure_chroot_dir) — doit exister sinon 500 OOPS
RUN mkdir -p /var/run/vsftpd/empty && chmod 755 /var/run/vsftpd/empty

COPY vsftpd.conf.template /etc/vsftpd.conf.template
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 21

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]
