#!/bin/bash

# 1. Crée les fichiers système de MariaDB (les tables de privilèges, les dictionnaires de données), si ils n'existent pas.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation du répertoire des données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 2. On lance MariaDB en arrière-plan (le & à la fin).
#    Pour configurer des utilisateurs avec la commande mysql -e, le serveur doit être en train de tourner. 
#    On le lance donc temporairement juste pour la configuration
mysqld_safe --user=mysql --datadir='/var/lib/mysql' &

# 3. Attendre que MariaDB réponde vraiment 
#    Le processus MariaDB peut prendre quelques secondes à s'initialiser. 
#    Si on essaie de créer l'utilisateur trop tôt, la commande échouera car le serveur ne répondra pas encore.
until mysqladmin ping >/dev/null 2>&1; do
    echo "En attente de MariaDB..."
    sleep 5
done

# 4. Configuration SQL
#    On injecte les commandes SQL pour créer la base WordPress, mon utilisateur, 
#    et on sécurise le compte root avec le mot de passe de mon .env.
#    FLUSH PRIVILEGES; : Dit à MariaDB de recharger les tables de permissions pour appliquer les changements immédiatement.
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

# 5. Éteindre proprement pour relancer au premier plan
#    Un conteneur Docker doit avoir un seul processus principal au premier plan. 
#    On éteint donc la version "fantôme" qu'on a lancée à l'étape 2.
#    On utilise maintenant -p${SQL_ROOT_PASSWORD} car le mot de passe root vient d'être activé à l'étape précédente.
mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

# 6. Lancer le processus final (CMD)
#    exec remplace le script shell par la commande définie dans le CMD de mon Dockerfile (mysqld ...).
#    MariaDB se relance, mais cette fois-ci au premier plan. C'est ce processus qui gardera mon conteneur en vie. 
#    Si ce processus s'arrête, le conteneur s'arrête.
exec "$@"