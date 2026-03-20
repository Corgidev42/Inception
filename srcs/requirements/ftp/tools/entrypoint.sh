#!/bin/sh
set -e

# Shell /bin/bash : pam_shells (common-account) bloque souvent nologin → 530 même avec check_shell=NO
if ! id ftpuser >/dev/null 2>&1; then
    useradd -o -u 33 -g 33 -d /var/www/html -s /bin/bash -M ftpuser
else
    usermod -s /bin/bash ftpuser 2>/dev/null || true
fi

# Secret obligatoire : sinon chpasswd ne tourne pas → mot de passe vide → 530
if [ ! -f /run/secrets/ftp_password ]; then
    echo "ftp: /run/secrets/ftp_password absent (vérifie secrets/ftp_password.txt au compose)" >&2
    exit 1
fi

FTP_PASS=$(tr -d '\r\n' < /run/secrets/ftp_password)
if [ -z "${FTP_PASS}" ]; then
    echo "ftp: secret ftp_password vide" >&2
    exit 1
fi

printf 'ftpuser:%s\n' "${FTP_PASS}" | chpasswd

mkdir -p /var/www/html
mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

# Mode passif : sans ça vsftpd annonce l'IP Docker (172.x) → LIST bloque depuis l'hôte
PASV_ADDR="${FTP_PASV_ADDRESS:-127.0.0.1}"
sed "s|__PASV_ADDRESS__|${PASV_ADDR}|g" /etc/vsftpd.conf.template > /etc/vsftpd.conf

exec "$@"
