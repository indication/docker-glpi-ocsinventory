CREATE DATABASE ocsinventory;
create user 'ocsinventory'@'%' identified by 'ocsinventorypass';
grant all on ocsinventory.* to 'ocsinventory'@'%';
FLUSH PRIVILEGES;
