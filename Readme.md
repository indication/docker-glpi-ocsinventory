docker-ocsinventory
====================

Dockerfile for [OCS Inventory](https://www.ocsinventory-ng.org/en/) ([github](https://github.com/OCSInventory-NG))

License
------------
Except the codes from origin, anothers are WTFPL2.
NO WARRANTY.

Installation
------------

### Configure `docker-compose.yml`

1. Change passwords and IDs
2. Run `docker-compose build`
3. Run `docker-compose up -d`
4. Access from browser
    http://docker-host:83/ocsreports   for OCS Inventory NG Console
    http://docker-host:83/download     for OCS Inventory NG download place (internal)
    http://docker-host:83/snmp         for OCS Inventory NG snmp place (internal)
    http://docker-host:83/ocsplugins   for OCS Inventory NG plugins (internal)
    http://docker-host:83/ocsinterface for OCS Inventory NG report from client
    http://docker-host:83/ocsapi       for OCS Inventory NG REST API (currently disabled)

Current version
------------

|Docker      |Package      |Version    |Note   |
|------------|-------------|-----------|-------|
|ocsinventory|OCS Inventory|2.7        |from github|
|ocsinventory|debian(base) |slim-latest|Official|
|ocsinventory|Perl         |5.28       |debian provided|
|ocsinventory|Apache       |2.4        |debian provided|
|glpidb      |MySQL        |5          |Minor version is not specified|
