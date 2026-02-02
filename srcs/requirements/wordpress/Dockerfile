FROM debian:trixie

#------- PHP-FPM INSTALL -------
RUN apt update 
RUN apt install -y php8.4-fpm 
RUN apt install -y php8.4-pdo 
RUN apt install -y php8.4-intl 
RUN apt install -y php8.4-zip 
RUN apt install -y php8.4-opcache 
RUN apt install -y php8.4-gd 
RUN apt install -y wget
RUN apt install -y php8.4-mysqli 

COPY ./www/html/ /tmp/src/

COPY ./conf/www.conf /etc/php/8.4/fpm/pool.d/

COPY ./conf/wp-config.php /tmp/src/

COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /var/www/html

CMD ["php-fpm8.4", "-F"]