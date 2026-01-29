FROM debian:trixie

#------- PHP-FPM INSTALL -------
RUN apt update \
    && apt install -y php8.4-fpm \
    wget

COPY ./www/html/ /tmp/src/

COPY ./conf/www.conf /etc/php/8.4/fpm/pool.d/

COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /var/www/html

CMD ["php-fpm8.4", "-F"]