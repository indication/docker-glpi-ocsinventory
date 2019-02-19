#!/bin/sh

# check parameters
: "${DB_HOST:?DB_HOST needs to be set}"
: "${DB_DATABASE:?DB_DATABASE needs to be set}"
: "${DB_USERNAME:?DB_USERNAME needs to be set}"
: "${DB_PASSWORD:?DB_PASSWORD needs to be set}"
MYSQLCMDBASE="mysql --host=${DB_HOST} --port=${DB_PORT:-3306} -ns --user=${DB_USERNAME} --password=${DB_PASSWORD} --database=${DB_DATABASE}"
$MYSQLCMDBASE -w --connect-timeout=100 -e "SELECT 'OK';" ||  echo "Failed to access ${DB_HOST}:${DB_PORT:-3306}" || exit 1;
#if [ `$MYSQLCMDBASE -w --connect-timeout=100 -e "show tables;" | wc -l` -eq "0" ] ; then
# setup for glpi
if [ ! -f "/var/www/html/glpi/config/config_db.php" ] ; then
  echo Setup first data
  sudo -u www-data -- php /var/www/html/glpi/scripts/cliinstall.php --host=${DB_HOST}:${DB_PORT:-3306} --user=${DB_USERNAME} --pass=${DB_PASSWORD} --db=${DB_DATABASE} --lang=${INIT_LANG:-en_US}
  mkdir -p /var/lib/glpi/_cron
  mkdir -p /var/lib/glpi/_dumps
  mkdir -p /var/lib/glpi/_graphs
  mkdir -p /var/lib/glpi/_lock
  mkdir -p /var/lib/glpi/_pictures
  mkdir -p /var/lib/glpi/_plugins
  mkdir -p /var/lib/glpi/_rss
  mkdir -p /var/lib/glpi/_sessions
  mkdir -p /var/lib/glpi/_tmp
  mkdir -p /var/lib/glpi/_uploads
  mkdir -p /var/lib/glpi/_cache
  chown -R www-data: /var/lib/glpi
fi


exec $@
