FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client git gd \
    openldap libressl libzip freetype libpng libjpeg-turbo \
    h2o supervisor

# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        openldap-dev libressl-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c patch \
    && php -i && sleep 20 \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) iconv xmlrpc zip imap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) ldap \
    && apk del --purge .php-buildapps


###################### DATA VOLUME  ########################
VOLUME ["/var/lib/glpi"]

####################### SERVER SETUP #######################
EXPOSE 80

# Setup H2O and supervisor and entrypoint
COPY supervisord.conf \
     h2o.conf \
     zzz-www.conf \
     entrypoint.sh \
     /tmp/
RUN set -ex \
      && mkdir -p /etc/glpi /var/log/glpi \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint.sh /etc/glpi/ \
      && chmod +x /etc/glpi/entrypoint.sh \
      && chown www-data:www-data -R /etc/glpi /var/log/glpi

# Put entry point to execute
ENTRYPOINT ["/etc/glpi/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

RUN php -i

############ INITIAL APPLICATION SETUP #####################
# DO NOT change the order of following commands
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html
USER www-data
ENV GLPI_VERSION 9.3.3
ENV GLPI_MD5SUM edf282d5e4d5f264df50d30819138acd
# Clone and dependencies
# Copy all configuration files and add alias(ln) to /snipeit
RUN set -ex \
    && curl -o /tmp/glpi.tar.gz -sSL https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz \
    && md5sum /tmp/glpi.tar.gz \
    && (echo "$GLPI_MD5SUM */tmp/glpi.tar.gz" | md5sum -c || (md5sum /tmp/glpi.tar.gz && exit 1)) \
    && tar -xzf /tmp/glpi.tar.gz --strip-components=1 \
    && rm /tmp/glpi.tar.gz \
    && ln -s . /var/www/html/glpi


USER root