docker-ocsinventory
====================

Dockerfile for [OCS Inventory](https://www.ocsinventory-ng.org/en/)

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

Current version
------------

|Docker      |Package      |Version    |Note   |
|------------|-------------|-----------|-------|
|ocsinventory|OCS Inventory|2.5        |from github|
|ocsinventory|debian(base) |slim-latest|Official|
|ocsinventory|Perl         |5.28       |debian provided|
|ocsinventory|Apache       |2.4        |debian provided|
|glpidb      |MySQL        |5          |Minor version is not specified|
