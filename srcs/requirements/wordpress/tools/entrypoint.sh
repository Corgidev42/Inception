#!/bin/sh
set -e

# 1. Attente de MariaDB
#    Docker lance les conteneurs presque en même temps. 
#	 WordPress démarre souvent avant que MariaDB n'ait fini d'initialiser ses bases.
#    nc (Netcat) interroge le port 3306 de l'hôte mariadb. Tant que le port est fermé, le script boucle. 
#	 Cela évite l'erreur fatale "Error establishing a database connection" au démarrage.
until nc -zv mariadb 3306; do
    echo "Le port 3306 de MariaDB est fermé - attente..."
    sleep 2
done
echo "Le port 3306 est ouvert !"


cd /var/www/html

# 2. Téléchargement des sources
#    On vérifie si index.php existe. Si non, on télécharge WordPress.
#	 --allow-root : WP-CLI refuse par défaut de s'exécuter en tant qu'utilisateur root. 
#    On le force ici car le conteneur tourne en root.
if [ ! -f index.php ]; then
    wp core download --allow-root
fi

if [ ! -f "wp-config.php" ]; then

# 3. Création du fichier wp-config.php
#    Il utilise mes variables d'environnement pour lier WordPress à ma base MariaDB.
#	 Cette commande génère automatiquement les "Salts" (clés de hachage uniques) dans le fichier, ce qui est une exigence de sécurité.
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root

# 4. Injection de PHP personnalisé
#    FS_METHOD : Permet d'installer des plugins ou thèmes sans que WordPress demande un accès FTP (très utile dans Docker).
#	 Indispensable car on utilises Nginx comme proxy SSL. 
#	 Ce code dit à WordPress : "Si le trafic arrive en HTTPS via le proxy, considère que le site est bien en HTTPS". 
#	 Sans ça, on risques des boucles de redirection infinies.
    wp config set FS_METHOD 'direct' --allow-root    
    cat <<EOF >> wp-config.php
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}
EOF

# 5. Installation et création d'utilisateurs
#    core install : Remplit les tables de la base de données et crée le compte Administrateur.
#	 user create : Crée le second utilisateur (rôle author).
    wp core install \
        --url=$DOMAIN_NAME \
        --title=$SITE_TITLE \
        --admin_user=$ADMIN_USER \
        --admin_password=$ADMIN_PASSWORD \
        --admin_email=$ADMIN_EMAIL \
        --allow-root

    wp user create $USER_LOGIN $USER_EMAIL --role=author --user_pass=$USER_PASS --allow-root
fi

# 6. Permissions et lancement final
#    chown : Donne la propriété des fichiers à www-data (l'utilisateur standard pour PHP-FPM). 
#	 Sans ça, WordPress ne pourra pas uploader d'images ou faire des mises à jour.
#	 exec "$@" : Elle remplace le script par le processus principal défini dans mon Dockerfile (php-fpm8.4 -F). 
#	 Cela permet au conteneur de rester vivant et de recevoir les signaux d'arrêt correctement.
chown -R www-data:www-data /var/www/html/
exec "$@"