#!/bin/sh

# check parameters
: "${OCS_DBNAME:?OCS_DBNAME needs to be set}"
: "${OCS_DBSERVER_READ:?OCS_DBSERVER_READ needs to be set}"
: "${OCS_DBSERVER_WRITE:?OCS_DBSERVER_WRITE needs to be set}"
: "${OCS_DBUSER:?OCS_DBUSER needs to be set}"
: "${OCS_DBPASS:?OCS_DBPASS needs to be set}"
MYSQLCMDBASE="mysql --port=${OCS_DB_PORT:-3306} -ns --user=${OCS_DBUSER} --password=${OCS_DBPASS} --database=${OCS_DBNAME}"
$MYSQLCMDBASE  --host=${OCS_DBSERVER_READ} -w --connect-timeout=100 -e "SELECT 'DBSERVER_READ OK';" ||  echo "Failed to access ${OCS_DBSERVER_READ}:${OCS_DB_PORT:-3306}" || exit 1;
for i in `seq 1 20`
do
  $MYSQLCMDBASE  --host=${OCS_DBSERVER_WRITE} -w --connect-timeout=100 -e "SELECT 'DBSERVER_WRITE OK';"
  if [ $? -eq 0 ]; then
    break
  fi
  if [ $i -eq 20 ]; then
    echo "Failed to access ${DB_HOST}:${DB_PORT:-3306}"
    exit 1
  fi
  sleep 2
done
#if [ `$MYSQLCMDBASE -w --connect-timeout=100 -e "show tables;" | wc -l` -eq "0" ] ; then
if [ ! -f "/usr/share/ocsinventory-reports/ocsreports/.buildready" ] ; then
  touch /usr/share/ocsinventory-reports/ocsreports/.buildready
  echo Setup first data
  DBCONFIG=/usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
  echo "<?php" > $DBCONFIG
  echo "    define('DB_NAME', '${OCS_DBNAME}');" >> $DBCONFIG
  echo "    define('SERVER_READ', '${OCS_DBSERVER_READ}');" >> $DBCONFIG
  echo "    define('SERVER_WRITE', '${OCS_DBSERVER_WRITE}');" >> $DBCONFIG
  echo "    define('COMPTE_BASE', '${OCS_DBUSER}');" >> $DBCONFIG
  echo "    define('PSWD_BASE', '${OCS_DBPASS}');" >> $DBCONFIG
  echo "    \$_SESSION['PSWD_BASE']=PSWD_BASE;" >> $DBCONFIG
  echo "?>" >> $DBCONFIG
  chown -R www-data:www-data /var/www/html \
   /etc/ocsinventory-server \
   /usr/share/ocsinventory-reports \
   /var/lib/ocsinventory-reports
fi

if [ ! -d /var/lib/ocsinventory-reports/ipd ]; then
  mkdir -p /var/lib/ocsinventory-reports/snmp
  mkdir -p /var/lib/ocsinventory-reports/download
  mkdir -p /var/lib/ocsinventory-reports/ipd
  chown www-data: -R /var/lib/ocsinventory-reports
  chmod -R g+w,o-w -R /var/lib/ocsinventory-reports/
fi

exec $@
