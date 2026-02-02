FROM debian:trixie

RUN apt -y update \
    && apt install -y nginx openssl\
    && rm /etc/nginx/sites-enabled/default \
    && rm /etc/nginx/sites-available/default 

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/vbonnard.key \
    -out /etc/nginx/ssl/vbonnard.crt \
    -subj "/C=FR/L=Paris/O=42/OU=vbonnard/CN=vbonnard.42.fr"

COPY ./conf/inception-site.conf /etc/nginx/sites-available/inception-site.conf

RUN ln -sf /etc/nginx/sites-available/inception-site.conf /etc/nginx/sites-enabled/inception-site.conf 

CMD ["nginx", "-g", "daemon off;"]