#!/bin/sh

if [ -f ./wp-config.php ]
then
	echo "wordpress est déjà installé"
else

	#Téléchargement de wordpress and de tous les fichiers de configurations
	wget http://wordpress.org/latest.tar.gz
	tar xfz latest.tar.gz
	mv wordpress/* /var/www/html 
	rm -rf latest.tar.gz
	rm -rf wordpress

fi 


# On force la copie des fichiers de l'image vers le volume
# On utilise un dossier temporaire /tmp/src comme source
cp -rf /tmp/src/* /var/www/html/

# On s'assure que les permissions sont correctes
chown -R www-data:www-data /var/www/html/



# On lance la commande originale (PHP-FPM)
exec "$@"