docker-glpi-ocsinventory
====================

Dockerfile for [GLPI](https://glpi-project.org/) ([github](https://github.com/glpi-project/glpi))

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
    http://docker-host:82/glpi for GLPI

Current version
------------

|Docker      |Package      |Version    |Note   |
|------------|-------------|-----------|-------|
|glpi        |GLPI         |9.4.1.1    |from github|
|glpi        |Plugin: [ocsinventoryng](https://github.com/pluginsGLPI/ocsinventoryng)|1.6.0|from github|
|glpi        |Plugin: [browsernotification](https://github.com/edgardmessias/browsernotification)|1.1.9|from github|
|glpi        |PHP(base)    |7.2-fpm-alpine  |Official|
|glpi        |H2O          |-          |alpine linux provided|
|glpi        |[IPA font](https://www.ipa.go.jp/osc/ipafont)|Ver.003.01|[IPA font license](https://ipafont.ipa.go.jp/ipa_font_license_v1-html#en)|
|glpidb      |MySQL        |5          |Minor version is not specified|
