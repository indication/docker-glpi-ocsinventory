FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client gd \
    openldap libressl libzip freetype libpng libjpeg-turbo net-snmp \
    fcgi fcgiwrap perl perl-utils perl-xml-libxml perl-xml-simple libxml2 \
    perl-net-ip perl-dbi perl-dbd-mysql perl-io-compress perl-archive-zip \
    h2o supervisor sudo

# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make autoconf file g++ \
        openldap-dev libressl-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c patch libc-dev net-snmp-dev \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) xmlrpc zip snmp soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) ldap \
    && apk del --purge .php-buildapps

############# BASE APPLICATION SETUP  ######################

# perl-date-format
RUN apk add -U --no-cache \
    perl-net-ssleay perl-lwp-protocol-https perl-path-tiny perl-xml-xpath perl-xml-twig \
    perl-test-failwarnings perl-test-mockrandom perl-test-fatal perl-unicode-string perl-test-mockobject \
    perl-xml-parser perl-data-uuid perl-fcgi perl-test-exception perl-algorithm-diff perl-text-diff \
    perl-test-differences perl-devel-stacktrace perl-class-data-inheritable perl-exception-class \
    perl-test-most perl-mime-tools perl-convert-binhex perl-test-deep perl-xml-sax \
    perl-test-requires perl-xml-parser perl-sub-uplevel perl-test-warnings perl-task-weaken perl-class-inspector
ENV OCS_VERSION 2.5
ENV OCS_MD5SUM e69dc47b7a458c0588ab1e170dea33f2
WORKDIR /tmp
#  SOAP::Lite
RUN set -ex \
    && mkdir -p /etc/ocsinventory-server/plugins \
    && mkdir -p /etc/ocsinventory-server/perl \
    && mkdir -p /usr/share/ocsinventory-reports/ocsreports \
    && mkdir -p /var/lib/ocsinventory-reports \
    && apk add -U --no-cache --virtual .perl-buildapps gcc make autoconf file g++ \
        perl-module-build perl-log-log4perl expat-dev expat \
        dpkg-dev dpkg re2c patch libc-dev \
    && cpan -i XML::Entities Mojolicious::Lite\
    && curl -o /tmp/ocs.tar.gz -sSL https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/$OCS_VERSION/OCSNG_UNIX_SERVER_$OCS_VERSION.tar.gz \
    && md5sum /tmp/ocs.tar.gz \
    && (echo "$OCS_MD5SUM */tmp/ocs.tar.gz" | md5sum -c || (md5sum /tmp/ocs.tar.gz && exit 1)) \
    && mkdir /tmp/ocs && cd /tmp/ocs \
    && tar -xzf /tmp/ocs.tar.gz --strip-components=1 \
    && rm /tmp/ocs.tar.gz \
    && cd Apache \
    && perl Makefile.PL && make -j$(nproc) && make install \
    && apk del --purge .perl-buildapps \
    && chown -R www-data:www-data /var/www/html /etc/ocsinventory-server /usr/share/ocsinventory-reports /var/lib/ocsinventory-reports

RUN set -ex \
    && rm -rf /usr/share/ocsinventory-reports/ocsreports \
    && mv /tmp/ocs/ocsreports /usr/share/ocsinventory-reports/ \
    && mv /tmp/ocs/binutils/ipdiscover-util.pl /usr/share/ocsinventory-reports/ocsreports/ \
    && chmod 755 /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl \
    && chown -R www-data:www-data /var/www/html /etc/ocsinventory-server /usr/share/ocsinventory-reports /var/lib/ocsinventory-reports
###################### DATA VOLUME  ########################
VOLUME ["/var/lib/ocsinventory-reports"]

####################### SERVER SETUP #######################
EXPOSE 80

# Setup H2O and supervisor and entrypoint
COPY supervisord.conf \
     h2o.conf \
     zzz-www.conf \
     entrypoint.sh \
     /tmp/
RUN set -ex \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint.sh /usr/share/ocsinventory-reports/ocsreports/ \
      && chmod +x /usr/share/ocsinventory-reports/ocsreports/entrypoint.sh

# Put entry point to execute
ENTRYPOINT ["/usr/share/ocsinventory-reports/ocsreports/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
