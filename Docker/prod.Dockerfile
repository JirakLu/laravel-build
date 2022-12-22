FROM alpine:3.16

RUN apk update && apk add --no-cache supervisor \
    alpine-base \
    alpine-baselayout \
    alpine-keys \
    apache2 \
    apache2-proxy \
    apk-tools \
    busybox \
    doas \
    libc-utils \
    logrotate \
    nano \
    openssh-server \
    openssh-sftp-server \
    php81 \
    php81-apache2 \
    php81-bcmath \
    php81-exif \
    php81-mysqli \
    php81-pdo_sqlite \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-fileinfo \
    php81-ftp \
    php81-fpm \
    php81-gd \
    php81-iconv \
    php81-json \
    php81-mbstring \
    php81-openssl \
    php81-pdo \
    php81-pgsql \
    php81-pdo_pgsql \
    php81-phar \
    php81-pcntl \
    php81-posix \
    php81-session \
    php81-sockets \
    php81-sodium \
    php81-simplexml \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-pdo_mysql \
    php81-zip \
    php81-pecl-mongodb \
    php81-pecl-imagick \
    postfix \
    py3-pymysql \
    python3 \
    shadow && rm -rf /var/cache/apk/*

COPY apache-configs /etc/apache2

COPY supervisord.conf /etc/supervisord.conf

COPY ./build /var/www/localhost/htdocs

RUN cd /var/www/localhost/htdocs/ && find . -type f -exec chmod 644 {} \;  && \
                                     find . -type d -exec chmod 755 {} \; && \
                                     chmod -R 777 ./storage && \
                                     chmod -R 777 ./bootstrap/cache/ && \
                                     chmod -R 777 ./node_modules/

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
