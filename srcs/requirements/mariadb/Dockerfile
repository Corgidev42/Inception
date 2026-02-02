FROM debian:trixie

RUN apt update
RUN apt install -y mariadb-server

RUN mkdir -p /var/run/mysqld \
&& chown -R mysql:mysql /var/run/mysqld \
&& chmod 777 /var/run/mysqld

# RUN mariadb -u root

RUN chown -R mysql:mysql /var/lib/mysql

USER mysql



CMD ["mysqld", "--bind-address=0.0.0.0"]