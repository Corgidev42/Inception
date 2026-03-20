#!/bin/bash
set -e

read_secret() {
  local var_name="$1"
  local file_var_name="${var_name}_FILE"
  local file_path="${!file_var_name:-}"
  if [ -n "${file_path}" ] && [ -f "${file_path}" ]; then
    export "${var_name}=$(cat "${file_path}")"
  fi
}

read_secret "SQL_PASSWORD"
read_secret "SQL_ROOT_PASSWORD"

# Marqueur « setup terminé » : base dédiée (dossier dans le datadir)
MARKER_DB="inception_meta"

is_configured() {
  [ -f "/var/lib/mysql/mysql/db.ibd" ] || [ -f "/var/lib/mysql/mysql/db.frm" ]
}

# Déjà prêt (nouveau marqueur ou ancien fichier)
if [ -d "/var/lib/mysql/${MARKER_DB}" ] && is_configured; then
  exec "$@"
fi
if [ -f "/var/lib/mysql/.inception_configured" ] && is_configured; then
  exec "$@"
fi

if [ -f "/var/lib/mysql/.inception_configured" ] && ! is_configured; then
  rm -f /var/lib/mysql/.inception_configured
fi

if [ -z "${SQL_DATABASE}" ] || [ -z "${SQL_USER}" ] || [ -z "${SQL_PASSWORD}" ] || [ -z "${SQL_ROOT_PASSWORD}" ]; then
  echo "Variables manquantes: SQL_DATABASE/SQL_USER/SQL_PASSWORD/SQL_ROOT_PASSWORD"
  exit 1
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 1. Répertoire de données : tables système si absentes ou datadir vide/corrompu
if ! is_configured; then
  echo "Initialisation du répertoire des données MariaDB..."
  rm -rf /var/lib/mysql/*
  rm -f /var/lib/mysql/.inception-init.sql
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql 2>/dev/null || \
  mysql_install_db --user=mysql --datadir=/var/lib/mysql
  chown -R mysql:mysql /var/lib/mysql
fi

# 2. Un seul processus mysqld au premier plan : --init-file exécute le SQL au démarrage
#    (pas de mysqld en arrière-plan, pas de &)
sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}
SP="$(sql_escape "${SQL_PASSWORD}")"
SRP="$(sql_escape "${SQL_ROOT_PASSWORD}")"

# Dans le datadir : mysqld (processus mysql) doit pouvoir lire le fichier (--init-file).
INIT_SQL="/var/lib/mysql/.inception-init.sql"
umask 077
{
  echo "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
  echo "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SP}';"
  echo "ALTER USER \`${SQL_USER}\`@'%' IDENTIFIED BY '${SP}';"
  echo "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SRP}';"
  echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  echo "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SRP}';"
  echo "ALTER USER 'root'@'%' IDENTIFIED BY '${SRP}';"
  echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
  echo "FLUSH PRIVILEGES;"
  echo "CREATE DATABASE IF NOT EXISTS \`${MARKER_DB}\`;"
  echo "CREATE TABLE IF NOT EXISTS \`${MARKER_DB}\`.\`initialized\` (id INT PRIMARY KEY);"
  echo "INSERT IGNORE INTO \`${MARKER_DB}\`.\`initialized\` VALUES (1);"
} > "${INIT_SQL}"

chown mysql:mysql "${INIT_SQL}"
chmod 640 "${INIT_SQL}"

# --init-file en tête (mysqld lit le fichier avant/après drop user selon versions)
# "$@" = mysqld --bind-address=0.0.0.0 --user=mysql
exec "$1" --init-file="${INIT_SQL}" "${@:2}"
