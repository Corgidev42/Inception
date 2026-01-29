#!/bin/sh

# On force la copie des fichiers de l'image vers le volume
# On utilise un dossier temporaire /tmp/src comme source
rm -rf /var/www/html/*
cp -rf /tmp/src/* /var/www/html/

# On s'assure que les permissions sont correctes
chown -R www-data:www-data /var/www/html/

# On lance la commande originale (PHP-FPM)
exec "$@"