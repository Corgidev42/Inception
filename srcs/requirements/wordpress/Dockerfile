FROM debian:trixie

# Installation de PHP et des dépendances
RUN apt update && apt install -y \
    php8.4-fpm \
    php8.4-mysqli \
    php8.4-curl \
    php8.4-dom \
    php8.4-exif \
    php8.4-fileinfo \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    mariadb-client \
    wget \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Installation de WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configuration de PHP-FPM (dossier run + pool config)
RUN mkdir -p /run/php
COPY ./conf/www.conf /etc/php/8.4/fpm/pool.d/

# Script d'entrée
COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# -F pour forcer PHP-FPM à rester au premier plan
CMD ["php-fpm8.4", "-F"]