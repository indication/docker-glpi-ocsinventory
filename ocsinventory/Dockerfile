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

# perl-date-format is error
RUN apk add -U --no-cache \
    perl perl-xml-libxml perl-xml-simple libxml2 \
    perl-net-ip perl-dbi perl-dbd-mysql perl-io-compress perl-archive-zip \
    perl-net-ssleay perl-lwp-protocol-https perl-path-tiny perl-xml-xpath perl-xml-twig \
    perl-unicode-string perl-xml-parser perl-data-uuid perl-algorithm-diff perl-text-diff \
    perl-devel-stacktrace perl-class-data-inheritable perl-exception-class \
    perl-mime-tools perl-convert-binhex perl-xml-sax perl-digest-sha1 \
    perl-xml-parser perl-sub-uplevel perl-task-weaken perl-class-inspector 

############# BASE APPLICATION SETUP  ######################
ENV OCS_VERSION 2.5
ENV OCS_MD5SUM e69dc47b7a458c0588ab1e170dea33f2
WORKDIR /tmp
# perl-utils is for cpan
RUN set -ex \
    && mkdir -p /etc/ocsinventory-server/plugins \
    && mkdir -p /etc/ocsinventory-server/perl \
    && mkdir -p /usr/share/ocsinventory-reports/ocsreports \
    && mkdir -p /var/lib/ocsinventory-reports \
    && apk add -U --no-cache --virtual .perl-buildapps gcc make autoconf file g++ \
        perl-module-build perl-log-log4perl expat-dev expat \
        patch libc-dev perl-utils \
        perl-test-failwarnings perl-test-mockrandom perl-test-fatal perl-test-mockobject \
        perl-test-exception perl-test-differences perl-test-most perl-test-deep perl-test-requires perl-test-warnings \
    && echo Create environment from cpan... \
    && cpan -i XML::Entities Mojolicious::Lite Apache::DBI \
    && echo Create environment without cpan becase it gets mutch error related to apache \
    && curl -o /tmp/soaplite.tar.gz -sSL https://cpan.metacpan.org/authors/id/P/PH/PHRED/SOAP-Lite-1.27.tar.gz \
    && mkdir soaplite && cd soaplite && tar xzf ../soaplite.tar.gz --strip-components=1 && rm ../soaplite.tar.gz \
    && perl Makefile.PL && make -j$(nproc) && make test && make install && cd .. && rm -rf soaplite \
    && echo Setup OCS Inventory \
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
