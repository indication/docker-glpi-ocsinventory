#!/bin/sh

# check parameters
: "${DB_HOST:?DB_HOST needs to be set}"
: "${DB_DATABASE:?DB_DATABASE needs to be set}"
: "${DB_USERNAME:?DB_USERNAME needs to be set}"
: "${DB_PASSWORD:?DB_PASSWORD needs to be set}"
MYSQLCMDBASE="mysql --host=${DB_HOST} --port=${DB_PORT:-3306} -ns --user=${DB_USERNAME} --password=${DB_PASSWORD} --database=${DB_DATABASE}"

for i in `seq 1 20`
do
  $MYSQLCMDBASE -w --connect-timeout=100 -e "SELECT 'OK';"
  if [ $? -eq 0 ]; then
    break
  fi
  if [ $i -eq 20 ]; then
    echo "Failed to access ${DB_HOST}:${DB_PORT:-3306}"
    exit 1
  fi
  sleep 2
done

# setup for glpi
CONFFILE=/var/www/html/glpi/config/config_db.php
GLPICLI=/var/www/html/glpi/bin/console
if [ ! -f "$CONFFILE" ] ; then
  echo Setup first data
  $MYSQLCMDBASE -w --connect-timeout=100 -e "SELECT * FROM glpi_configs WHERE 1=0;"
  if [ $? -gt 0 ]; then
      echo Initialize data
      sudo -u www-data -- $GLPICLI glpi:database:install --db-host=${DB_HOST} --db-port=${DB_PORT:-3306} --db-user=${DB_USERNAME} --db-password=${DB_PASSWORD} --db-name=${DB_DATABASE} --default-language=${INIT_LANG:-en_US}
  else
      echo Run update
      echo "<?" > $CONFFILE
      echo "class DB extends DBmysql {" >> $CONFFILE
      echo "   public \$dbhost     = '${DB_HOST}:${DB_PORT:-3306}';" >> $CONFFILE
      echo "   public \$dbuser     = '${DB_USERNAME}';" >> $CONFFILE
      echo "   public \$dbpassword = '${DB_PASSWORD}';" >> $CONFFILE
      echo "   public \$dbdefault  = '${DB_DATABASE}';" >> $CONFFILE
      echo "}" >> $CONFFILE
      sudo chown www-data: $CONFFILE
      sudo -u www-data -- $GLPICLI glpi:database:update
      sudo -u www-data -- $GLPICLI glpi:database:check
  fi
  mkdir -p /var/lib/glpi/_cron
  mkdir -p /var/lib/glpi/_dumps
  mkdir -p /var/lib/glpi/_graphs
  mkdir -p /var/lib/glpi/_lock
  mkdir -p /var/lib/glpi/_pictures
  mkdir -p /var/lib/glpi/_plugins
  mkdir -p /var/lib/glpi/_rss
  mkdir -p /var/lib/glpi/_sessions
  mkdir -p /var/lib/glpi/_logs
  mkdir -p /var/lib/glpi/_tmp
  mkdir -p /var/lib/glpi/_uploads
  mkdir -p /var/lib/glpi/_cache
  chown -R www-data: /var/lib/glpi
fi


exec $@
