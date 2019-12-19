FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client gd \
    openldap libressl libzip freetype libpng libjpeg-turbo \
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
    && apk del --purge .php-buildapps \
    && mkdir -p /var/www/html/glpi


###################### DATA VOLUME  ########################
VOLUME ["/var/lib/glpi"]

############ INITIAL APPLICATION SETUP #####################
# DO NOT change the order of following commands
WORKDIR /var/www/html/glpi
RUN chown -R www-data:www-data /var/www/html
USER www-data
ENV GLPI_VERSION 9.4.5
ENV GLPI_MD5SUM 595b8349424f209a5ad6cd9890e7d92f
# Clone and dependencies
# Copy all configuration files and add alias(ln) to /glpi
RUN set -ex \
    && curl -o /tmp/glpi.tar.gz -sSL https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz \
    && (echo "$GLPI_MD5SUM */tmp/glpi.tar.gz" | md5sum -c || (md5sum /tmp/glpi.tar.gz && exit 1)) \
    && tar -xzf /tmp/glpi.tar.gz --strip-components=1 \
    && rm install/install.php \
    && rm -rf files \
    && rm /tmp/glpi.tar.gz
RUN set -ex \
    && curl -o /tmp/font.zip -sSL https://ipafont.ipa.go.jp/IPAfont/ipag00303.zip \
    && mkdir /tmp/work \
    && unzip /tmp/font.zip -j -d /tmp/work \
    && rm /tmp/font.zip \
    && php vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /tmp/work/ipag.ttf \
    && rm -rf /tmp/work
    
# setup plugins
RUN set -ex \
    && export PLUGIN_VERSION=1.6.0 \
    && export PLUGIN_NAME=ocsinventoryng \
    && export PLUGIN_MD5SUM=8e328b48c6549d075e8ee8519907ff92 \
    && curl -o /tmp/$PLUGIN_NAME.tar.gz -sSL https://github.com/pluginsGLPI/$PLUGIN_NAME/releases/download/$PLUGIN_VERSION/glpi-$PLUGIN_NAME-$PLUGIN_VERSION.tar.gz \
    && (echo "$PLUGIN_MD5SUM */tmp/$PLUGIN_NAME.tar.gz" | md5sum -c || (md5sum /tmp/$PLUGIN_NAME.tar.gz && exit 1)) \
    && mkdir -p plugins/$PLUGIN_NAME \
    && cd plugins/$PLUGIN_NAME \
    && tar -xzf /tmp/$PLUGIN_NAME.tar.gz --strip-components=1 \
    && cd ../.. \
    && rm /tmp/$PLUGIN_NAME.tar.gz
# setup plugins
RUN set -ex \
    && export PLUGIN_VERSION=1.1.9 \
    && export PLUGIN_NAME=browsernotification \
    && export PLUGIN_MD5SUM=a3be42ebc136aebe180b08859e4662dd \
    && curl -o /tmp/$PLUGIN_NAME.tar.gz -sSL https://github.com/edgardmessias/browsernotification/archive/$PLUGIN_VERSION.tar.gz \
    && (echo "$PLUGIN_MD5SUM */tmp/$PLUGIN_NAME.tar.gz" | md5sum -c || (md5sum /tmp/$PLUGIN_NAME.tar.gz && exit 1)) \
    && mkdir -p plugins/$PLUGIN_NAME \
    && cd plugins/$PLUGIN_NAME \
    && tar -xzf /tmp/$PLUGIN_NAME.tar.gz --strip-components=1 \
    && cd ../.. \
    && rm /tmp/$PLUGIN_NAME.tar.gz
    
USER root

# Local patch for LDAPS
RUN set -ex \
    && apk add -U --no-cache --virtual .patch-buildapps patch \
    && curl -o /tmp/ldaps.patch -sSL https://github.com/indication/glpi/commit/20cdeba65f7c2508fbd9bdf895bedb67bcd7acdc.patch \
    && cat /tmp/ldaps.patch \
    && sudo -u www-data patch -u -p1 -F100 < /tmp/ldaps.patch \
    && rm /tmp/ldaps.patch \
    && apk del --purge .patch-buildapps

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
      && echo "*/5    *       *       *       *       php /var/www/html/glpi/front/cron.php >& /dev/null" > crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/bin/console glpi:ldap:synchronize_users  | grep -v 'No active LDAP server found.'" >> crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/plugins/ocsinventoryng/scripts/ocsng_fullsync.sh --thread_nbr=2 " >> crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/plugins/ocsinventoryng/scripts/ocsng_snmpfullsync.sh --thread_nbr=2 " >> crond.txt \
      && cat crond.txt | crontab -u www-data - && rm crond.txt \
      && chmod +x /var/www/html/glpi/plugins/ocsinventoryng/scripts/*.sh \
      && mv /tmp/local_define.php /var/www/html/glpi/config/ \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint.sh / \
      && chmod +x /entrypoint.sh

# Put entry point to execute
ENTRYPOINT ["/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
