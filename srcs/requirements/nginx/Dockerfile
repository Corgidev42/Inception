FROM debian:trixie

RUN apt -y update \
    && apt install -y nginx \
    && rm /etc/nginx/sites-enabled/default \
    && rm /etc/nginx/sites-available/default 

COPY ./conf/inception-site.conf /etc/nginx/sites-available/inception-site.conf

RUN ln -sf /etc/nginx/sites-available/inception-site.conf /etc/nginx/sites-enabled/inception-site.conf 

CMD ["nginx", "-g", "daemon off;"]