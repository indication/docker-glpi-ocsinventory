docker-glpi-ocsinventory
====================

Dockerfile for [GLPI](https://glpi-project.org/) ([github](https://github.com/glpi-project/glpi))

License
------------
Except the codes from origin, anothers are WTFPL2.
NO WARRANTY.
If you use IPA font, you must agree [IPA Font License Agreement v1.0](https://ipafont.ipa.go.jp/ipa_font_license_v1-html#en).

Installation
------------

### Configure `docker-compose.yml`

1. Change passwords and IDs
2. Run `docker-compose build`
3. Run `docker-compose up -d`
4. Access from browser
    http://docker-host:82/glpi for GLPI

Current version
------------

|Docker      |Package      |Version    |Note   |
|------------|-------------|-----------|-------|
|glpi        |GLPI         |9.4.5      |from github|
|glpi        |Plugin: [ocsinventoryng](https://github.com/pluginsGLPI/ocsinventoryng)|1.6.0|from github|
|glpi        |Plugin: [browsernotification](https://github.com/edgardmessias/browsernotification)|1.1.9|from github|
|glpi        |Patch:  [LDAPS Patch](https://github.com/indication/glpi/commit/20cdeba65f7c2508fbd9bdf895bedb67bcd7acdc) |-     |from github, Allow to connect LDAP SSL (not TLS)|
|glpi        |PHP(base)    |7.2-fpm-alpine  |Official|
|glpi        |H2O          |-          |alpine linux provided|
|glpi        |[IPA font](https://www.ipa.go.jp/osc/ipafont)|Ver.003.03|[IPA font license](https://ipafont.ipa.go.jp/ipa_font_license_v1-html#en)|
|glpidb      |MySQL        |5          |Minor version is not specified|


GLPI on docker
============

Environment variables
-------------

|Key        |Description                |Example     |
|-----------|---------------------------|------------|
|DB_HOST    |MySQL hostname             |glpidb      |
|DB_DATABASE|MySQL Database name        |glpi        |
|DB_USERNAME|MySQL user name for connect|glpi        |
|DB_PASSWORD|MySQL password for connect |glpipass    |
|TZ         |Timezone                   |Asia/Tokyo  |


Volumes
------------

- /var/lib/glpi
    - GLPI datastorage

Database
------------

- MySQL 5.x
- MySQL 8.x may NOT work
- You would be able to connect with mariadb

Port and HTTP requests
------------

- HTTP port to 80
- Subdirectory: glpi
- Recommend location behind reverse proxy (eg. nginx)

Setup
------------

- First user is `glpi`. Password is `glpi`.

... write more later....

Internals: cron
-------------

You do not need to call sync from external ways.
The cron is working at this container.

|Command                    |Frenquency     |Note               |
|---------------------------|---------------|-------------------|
|cron.php                   |Every 5 minutes|glpi cron          |
|glpi:ldap:synchronize_users|Every 5 minutes|Sync to LDAP if set|
|(plugin)ocsng_fullsync     |Every 5 minutes|OCS Inventory sync |
|(plugin)ocsng_snmpfullsync |Every 5 minutes|OCS Inventory sync |

Security
-------------

- Block access `/glpi/config` as 403
- Hide `x-powered-by`
