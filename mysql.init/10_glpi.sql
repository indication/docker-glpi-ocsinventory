CREATE DATABASE glpi
create user 'glpi'@"%" identified by "glpipass";
grant all on glpi.* to 'glpi'@"%";
FLUSH PRIVILEGES;

