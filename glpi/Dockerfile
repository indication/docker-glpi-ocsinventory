FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client gd \
    openldap libressl libzip freetype libpng libjpeg-turbo \
    font-ipa \
    h2o supervisor imap-dev sudo musl c-client
# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        openldap-dev libressl-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c patch libc-dev musl-dev \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) xmlrpc zip opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-imap --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) ldap \
    && pecl install apcu \
    && pecl clear-cache \
    && docker-php-ext-enable apcu opcache imap \
    && apk del --purge .php-buildapps


###################### DATA VOLUME  ########################
VOLUME ["/var/lib/glpi"]

############ INITIAL APPLICATION SETUP #####################
# DO NOT change the order of following commands
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html
USER www-data
ENV GLPI_VERSION 9.3.3
ENV GLPI_MD5SUM edf282d5e4d5f264df50d30819138acd
# Clone and dependencies
# Copy all configuration files and add alias(ln) to /glpi
RUN set -ex \
    && curl -o /tmp/glpi.tar.gz -sSL https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz \
    && md5sum /tmp/glpi.tar.gz \
    && (echo "$GLPI_MD5SUM */tmp/glpi.tar.gz" | md5sum -c || (md5sum /tmp/glpi.tar.gz && exit 1)) \
    && tar -xzf /tmp/glpi.tar.gz --strip-components=1 \
    && rm install/install.php \
    && rm /tmp/glpi.tar.gz \
    && vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /usr/share/fonts/TTF/ipagp.ttf
    && ln -s . /var/www/html/glpi

# setup plugins
RUN set -ex \
    && export PLUGIN_VERSION=1.5.6 \
    && export PLUGIN_NAME=ocsinventoryng \
    && export PLUGIN_MD5SUM=b31000dc9be0f79fee40a04bdd7332bf \
    && curl -o /tmp/$PLUGIN_NAME.tar.gz -sSL https://github.com/pluginsGLPI/$PLUGIN_NAME/releases/download/$PLUGIN_VERSION/glpi-$PLUGIN_NAME-$PLUGIN_VERSION.tar.gz \
    && (echo "$PLUGIN_MD5SUM */tmp/$PLUGIN_NAME.tar.gz" | md5sum -c || (md5sum /tmp/$PLUGIN_NAME.tar.gz && exit 1)) \
    && mkdir -p plugins/$PLUGIN_NAME \
    && cd plugins/$PLUGIN_NAME \
    && tar -xzf /tmp/$PLUGIN_NAME.tar.gz --strip-components=1 \
    && cd ../.. \
    && rm /tmp/$PLUGIN_NAME.tar.gz
    
USER root


####################### SERVER SETUP #######################
EXPOSE 80

# Setup H2O and supervisor and entrypoint
COPY supervisord.conf \
     h2o.conf \
     zzz-www.conf \
     entrypoint.sh \
     local_define.php \
     /tmp/
RUN set -ex \
      && mkdir -p /etc/glpi /var/log/glpi \
      && mv /tmp/local_define.php /etc/glpi/ \
      && chown www-data:www-data -R /etc/glpi /var/lib/glpi /var/log/glpi \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint.sh /etc/glpi/ \
      && chmod +x /etc/glpi/entrypoint.sh

# Put entry point to execute
ENTRYPOINT ["/etc/glpi/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
