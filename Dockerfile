FROM alpine:3.12

MAINTAINER Grupo W <developer@grupow.com>

ENV S6RELEASE v1.22.1.0
ENV S6URL     https://github.com/just-containers/s6-overlay/releases/download/
ENV S6_READ_ONLY_ROOT 1

RUN \
# Install dependencies
    apk add --no-cache gnupg nginx php7-fpm php7-json php7-gd \
        php7-intl php7-opcache php7-pdo_mysql php7-mysqli php7-mysqlnd tzdata \
        php7-tokenizer php7-bcmath php7-mcrypt php7-cli php7-common \
        php7-curl php7-mbstring php7-soap php7-xml php7-xmlrpc php7-xmlreader \
        php7-zip php7-ctype php7-simplexml php7-dom php7-xmlwriter \
        php7-zlib php7-phar php7-openssl php7-session php7-iconv php7-gmp php7-apcu \
        libmcrypt-dev zlib-dev gmp-dev \
        curl zip unzip && apk upgrade --no-cache \
# Remove (some of the) default nginx config
    && rm -f /etc/nginx.conf /etc/nginx/conf.d/default.conf /etc/php7/php-fpm.d/www.conf \
    && rm -rf /etc/nginx/sites-* \
# Ensure nginx logs, even if the config has errors, are written to stderr
    && ln -s /dev/stderr /var/log/nginx/error.log \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg2 --list-public-keys || /bin/true \
# Install s6 overlay for service management
    && wget -qO - https://keybase.io/justcontainers/key.asc | gpg2 --import - \
    && cd /tmp \
    && S6ARCH=$(uname -m) \
    && case ${S6ARCH} in \
           x86_64) S6ARCH=amd64;; \
           armv7l) S6ARCH=armhf;; \
       esac \
    && wget -q ${S6URL}${S6RELEASE}/s6-overlay-${S6ARCH}.tar.gz.sig \
    && wget -q ${S6URL}${S6RELEASE}/s6-overlay-${S6ARCH}.tar.gz \
    && gpg2 --verify s6-overlay-${S6ARCH}.tar.gz.sig \
    && tar -xzf s6-overlay-${S6ARCH}.tar.gz -C / \
# Support running s6 under a non-root user
    && mkdir -p /etc/services.d/nginx/supervise /etc/services.d/php-fpm7/supervise \
    && mkfifo \
        /etc/services.d/nginx/supervise/control \
        /etc/services.d/php-fpm7/supervise/control \
        /etc/s6/services/s6-fdholderd/supervise/control \
    && adduser nobody www-data \
    && chown -R nobody.www-data /etc/services.d /etc/s6 /run /var/lib/nginx /var/www \
# Clean up
    && rm -rf "${GNUPGHOME}" /tmp/* \
    && apk del gnupg

COPY etc/ /etc/

WORKDIR /var/www
USER nobody:www-data

# COPY web/ ./web
# COPY vendor/ ./vendor
# mark dirs as volumes that need to be writable, allows running the container --read-only
# VOLUME /config /var/www/config
# VOLUME /vendor /var/www/vendor
# VOLUME /web /var/www/web

EXPOSE 8080

ENTRYPOINT ["/init"]
