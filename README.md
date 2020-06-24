
<p>
  <img src="https://img.shields.io/badge/build-passed-brightgreen" alt="Build Status">
  <img src="https://img.shields.io/badge/version-v.1.0-blue" alt="Version">
</p>

# Docker Lemp Scriptstack

Docker, Traefik, NGINX Webserver, MariaDB, PHPMyAdmin, Mautic | LetsEncrypt + Extended security layer (htaccess)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine or on a live server for development or production.

### Prerequisites

These are the prerequisites which are required to install the stackscript

1. Docker

2. Docker Compose

3. Domain at Cloudflare

4. A Record with @ | A Wildcard Record with * => All pointed to your IP

5. Cloudflare custom API Token with ZONE:ZONE:READ & ZONE:DNS:EDIT

### Installing

A step by step guide that tells you how to get everything running

Navigate to opt folder

```
cd opt
```

Create Docker folder

```
mkdir docker
```

Navigate into docker folder

```
cd docker
```

Clone Git repository

```
git clone https://github.com/soerenmuenster/docker-lemp.git {your_project_name}
```
Navigate into {your_project_name}
```
cd {your_project_name}
```

Run Stackscript and follow instructions

```
sh install.sh
```

If everything went well you are ready to go. The script outputs following:
```
traefik.example.com <= Traefik Dashboard
```
```
pma.example.com <= phpMyAdmin
```
```
mautic.example.com <= Mautic
```
```
example.com <= NGINX Web-Server
```
## Important information
* !!! IMPORTANT !!! If the installation of the lemp stack is done, do not lose or delete the acme.json file. In this file Traefik saves all LetsEncrypt certificates. If you request certificates for your domain too often, LetsEncrypt will ban you for a week!

* If the Mautic installation fails in the third step you need to clear the cache of Mautic. You can clear the cache by deleting all files and folders in ./mautic/web/app/cache/
```
rm -rf {your_project_name}/mautic/web/app/cache/*
```
## Built With

* [Docker](https://www.docker.com/) - Docker
* [Docker-Compose](https://www.docker.com/) - Docker Compose
* [MariaDB](https://mariadb.org/) - MariaDB
* [PHP](https://www.php.net/) - PHP
* [Nginx](https://nginx.org/) - Nginx
* [phpMyAdmin](https://www.phpmyadmin.net/) - phpMyAdmin
* [Mautic](https://www.mautic.org/) - Mautic

## Authors

* **Dennis Ickes** - *Initial work* - [Website](https://dennisickes.de)

* **Sören Münster** - *Assistance work* - [Website](https://soerenmuenster.de)


## License

This project is licensed under the GNU General Public License v3.0 - check the [LICENSE](LICENSE) file for details
