FROM debian:stretch-slim

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       ca-certificates \
       curl \
       perl \
       libxml-simple-perl \
       libnet-ip-perl \
       libxml-libxml-perl \
       libapache2-mod-perl2 \
       libdbi-perl \
       libapache-dbi-perl \
       libdbd-mysql-perl \
       libio-compress-perl \
       libxml-simple-perl \
       libsoap-lite-perl \
       libarchive-zip-perl \
       libnet-ip-perl \
       libsoap-lite-perl \
       tar \
       nmap \
       samba \
       libapache2-mod-php7.0 \
       php7.0-gd \
       php7.0-mysql \
       php7.0-cgi \
       php7.0-curl \
       php7.0-xml \
       php7.0-soap \
       php7.0-zip \
       php-mbstring \
       php-pclzip \
       supervisor \
       mysql-client \
    && apt-get install -y --no-install-recommends \
       libplack-perl \
       libmojolicious-perl \
       libswagger2-perl \
       libswitch-perl \
    && a2dissite 000-default \
    && a2enmod rewrite \
    && a2enmod authz_user \
    && a2dismod -f autoindex \
    && apt-get clean \
    && rm -fr /var/cache/apt/* /var/lib/apt/lists/*

############# BASE APPLICATION SETUP  ######################
ENV OCS_VERSION 2.5
ENV OCS_MD5SUM e69dc47b7a458c0588ab1e170dea33f2
WORKDIR /tmp
# perl-utils is for cpan
RUN set -ex \
    && export BUILD_PACKAGES="\
       libc6-dev \
       build-essential \
       patch \
       apache2-dev \
       libmodule-build-perl \
       "\
    && mkdir -p /etc/ocsinventory-server/plugins \
    && mkdir -p /etc/ocsinventory-server/perl \
    && mkdir -p /usr/share/ocsinventory-reports \
    && mkdir -p /var/lib/ocsinventory-reports \
    && mkdir -p /var/log/ocsinventory-server \
    && chown www-data: /var/log/ocsinventory-server \
    && apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_PACKAGES \
    && echo Create environment from cpan... \
    && cpan -i XML::Entities Apache2::SOAP \
    && echo Setup OCS Inventory \
    && curl -o /tmp/ocs.tar.gz -sSL https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/$OCS_VERSION/OCSNG_UNIX_SERVER_$OCS_VERSION.tar.gz \
    && md5sum /tmp/ocs.tar.gz \
    && (echo "$OCS_MD5SUM */tmp/ocs.tar.gz" | md5sum -c || (md5sum /tmp/ocs.tar.gz && exit 1)) \
    && mkdir /tmp/ocs && cd /tmp/ocs \
    && tar -xzf /tmp/ocs.tar.gz --strip-components=1 \
    && rm /tmp/ocs.tar.gz \
    && cd Apache \
    && perl Makefile.PL && make -j$(nproc) && make install \
    && cd .. \
    && mv /tmp/ocs/ocsreports /usr/share/ocsinventory-reports/ \
    && mv /tmp/ocs/binutils/ipdiscover-util.pl /usr/share/ocsinventory-reports/ocsreports/ \
    && cat /tmp/ocs/etc/ocsinventory/ocsinventory-server.conf \
       | sed -re 's#OCS_MODPERL_VERSION\s+VERSION_MP#OCS_MODPERL_VERSION 2#' \
       | sed -re 's#OCS_DB_HOST\s+DATABASE_SERVER#OCS_DB_HOST ${OCS_DBSERVER_WRITE}#' \
       | sed -re 's#OCS_DB_PORT\s+DATABASE_PORT#OCS_DB_PORT 3306#' \
       | sed -re 's#OCS_DB_NAME\s+\w+#OCS_DB_NAME ${OCS_DBNAME}#' \
       | sed -re 's#OCS_DB_USER\s+\w+#OCS_DB_USER ${OCS_DBUSER}#' \
       | sed -re 's#OCS_DB_PWD\s+\w+#OCS_DB_PWD ${OCS_DBPASS}#' \
       | sed -e 's#PATH_TO_LOG_DIRECTORY#/var/log/ocsinventory-server#' \
       | sed -e 's#PATH_TO_PLUGINS_PERL_DIRECTORY#/etc/ocsinventory-server/perl#' \
       | sed -e 's#PATH_TO_PLUGINS_CONFIG_DIRECTORY#/etc/ocsinventory-server/plugins#' \
       > /etc/apache2/conf-available/ocsinventory-server.conf \
    && cat /tmp/ocs/etc/ocsinventory/ocsinventory-reports.conf \
       | sed -e "s#PATH_TO_OCSREPORTS_DIR#/usr/share/ocsinventory-reports/ocsreports#g" \
       | sed -e "s#OCSREPORTS_ALIAS#/ocsreports#" \
       | sed -e "s#PATH_TO_PACKAGES_DIR#/var/lib/ocsinventory-reports/download#g" \
       | sed -e "s#PACKAGES_ALIAS#/download#" \
       | sed -e "s#PATH_TO_SNMP_DIR#/var/lib/ocsinventory-reports/snmp#g" \
       | sed -e "s#SNMP_ALIAS#/snmp#" \
       > /etc/apache2/conf-available/ocsinventory-reports.conf \
    && export REST_API_DIRECTORY=$(perl -e 'print "@INC[2]"') \
    && cp -r /tmp/ocs/Api/ $REST_API_DIRECTORY \
    && echo Copy build result to API dir \
    && cp -r /tmp/ocs/Apache/blib/lib/Apache $REST_API_DIRECTORY \
    && cat /tmp/ocs/etc/ocsinventory/ocsinventory-restapi.conf \
       | sed -e "s#REST_API_PATH#${REST_API_DIRECTORY}#" \
       | sed -re 's/(\$ENV\{OCS_DB_HOST\})/#\1/' \
       | sed -re 's/(\$ENV\{OCS_DB_PORT\})/#\1/' \
       | sed -re 's/(\$ENV\{OCS_DB_LOCAL\})/#\1/' \
       | sed -re 's/(\$ENV\{OCS_DB_USER\})/#\1/' \
       | sed -re 's/(\$ENV\{OCS_DB_PWD\})/#\1/' \
       | sed -e "s#REST_API_LOADER_PATH#${REST_API_DIRECTORY}/Api/Ocsinventory/Restapi/Loader.pm#" \
       > /etc/apache2/conf-available/ocsinventory-restapi.conf \
    && a2enconf ocsinventory-server \
    && a2enconf ocsinventory-reports \
    && a2enconf ocsinventory-restapi \
    && echo Cleanup build modules... \
    && apt-get purge -y $BUILD_PACKAGES \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -fr /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf /tmp/ocs ~/.cpan \
    && chown -R www-data:www-data \
       /var/www/html /etc/ocsinventory-server \
       /usr/share/ocsinventory-reports \
       /var/lib/ocsinventory-reports \
       /var/log/ocsinventory-server \
    && chmod gou+x /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl
###################### DATA VOLUME  ########################
VOLUME ["/var/lib/ocsinventory-reports"]

####################### SERVER SETUP #######################
EXPOSE 80
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2f
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2

# Setup Apache2 and supervisor and entrypoint
COPY supervisord.conf \
     entrypoint.sh \
     /tmp/
RUN set -ex \
    && mv /tmp/supervisord.conf /etc/ \
    && chmod 644 /etc/supervisord.conf \
    && mv /tmp/entrypoint.sh /usr/share/ocsinventory-reports/ocsreports/ \
    && chmod +x /usr/share/ocsinventory-reports/ocsreports/entrypoint.sh

# Put entry point to execute
ENTRYPOINT ["/usr/share/ocsinventory-reports/ocsreports/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
