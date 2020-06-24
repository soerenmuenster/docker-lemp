#!/bin/bash

# COLOURS
RESET='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

info() {
   printf "${YELLOW}INFO $RESET>> $1 $RESET\n"
}

error() {
   printf "${RED}ERROR $RESET>> $1 $RESET\n"
}

# This part introduces the user to the script
info ""
info "${YELLOW}██████╗░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░░░░░░░██╗░░░░░███████╗███╗░░░███╗██████╗░"
info "${YELLOW}██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗░░░░░░██║░░░░░██╔════╝████╗░████║██╔══██╗"
info "${YELLOW}██║░░██║██║░░██║██║░░╚═╝█████═╝░█████╗░░██████╔╝█████╗██║░░░░░█████╗░░██╔████╔██║██████╔╝"
info "${YELLOW}██║░░██║██║░░██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗╚════╝██║░░░░░██╔══╝░░██║╚██╔╝██║██╔═══╝░"
info "${YELLOW}██████╔╝╚█████╔╝╚█████╔╝██║░╚██╗███████╗██║░░██║░░░░░░███████╗███████╗██║░╚═╝░██║██║░░░░░"
info "${YELLOW}╚═════╝░░╚════╝░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░░░░░░╚══════╝╚══════╝╚═╝░░░░░╚═╝╚═╝░░░░░"
info "${WHITE} AUTHOR: ${YELLOW}Dennis Ickes     ${WHITE}VERSION: ${YELLOW}0.1                                           ${WHITE}[${YELLOW}INSTALL${WHITE}]"
info ""
info "${WHITE}Starting ${YELLOW}docker-lemp ${WHITE}installation..."
apt-get install -y apache2-utils
#

# This part checks if the docker-compose.yml file exists in the directory
FILE_COMPOSE=./docker-compose.yml
info "${WHITE}Searching for ${YELLOW}${FILE_COMPOSE} ${WHITE}file..."
if [ ! -f "$FILE_COMPOSE" ]; then
   error "${WHITE} The file ${RED}${FILE_COMPOSE} ${WHITE}does not exist in this directory."
   exit 1
fi
info "${WHITE}File ${YELLOW}${FILE_COMPOSE} ${WHITE}found!"
#

# This part checks if the traefik.yml file exists in the directory
FILE_TRAEFIK=./traefik.yml
info "${WHITE}Searching for ${YELLOW}${FILE_TRAEFIK} file..."
if [ ! -f "$FILE_TRAEFIK" ]; then
   error "${WHITE}The file ${RED}${FILE_TRAEFIK} ${WHITE}does not exist in this directory."
   exit 1
fi
info "${WHITE}File ${YELLOW}${FILE_TRAEFIK} ${WHITE}found!"
#

# This part checks if the acme.json file exists. If not, it creates a new clear
# acme.json file. If the acme.json file already exists, the script clears the
# acme.json file.
FILE_ACME=./acme.json
info "${WHITE}Searching for ${YELLOW}${FILE_ACME} ${WHITE}file..."
if [ ! -f "$FILE_ACME" ]; then
   info "${WHITE}The file ${YELLOW}${FILE_ACME} ${WHITE}does not exist. Creating a new acme.json file..."
   touch ${FILE_ACME}
fi
chmod 600 ${FILE_ACME}
#

# This part asks the user for the relevant data (Domain, E-Mail, & Token)
info "${WHITE}Starting configuration for the files: ${YELLOW}${FILE_COMPOSE} & ${FILE_TRAEFIK}${WHITE}..."
printf "${WHITE}Please enter your ${YELLOW}Domain${WHITE}: ${YELLOW}"
read -p "" domain
info "${WHITE}Domain name ${YELLOW}${domain} ${WHITE}registered!"

printf "${WHITE}Please enter your ${YELLOW}e-mail ${WHITE}(for the SSL-Certificate): ${YELLOW}"
read -p "" email
info "${WHITE}E-Mail Address ${YELLOW}${email} ${WHITE}registered!"

printf "${WHITE}Please enter your ${YELLOW}API-Token ${WHITE}for cloudflare: ${YELLOW}"
read -p "" token
info "${WHITE}API-Token ${YELLOW}${token} ${WHITE}registered!"
#

# This part replaces the placeholders in the files with the given data (docker-compose.yml &, traefik.yml)
info "${WHITE}Replacing domain placeholders with ${YELLOW}${domain} ${WHITE}in ${YELLOW}${FILE_COMPOSE}${WHITE}..."
sed -i "s/{DOMAIN}/$domain/g" ${FILE_COMPOSE}

info "${WHITE}Replacing E-Mail placeholders with ${YELLOW}${email} ${WHITE}in ${YELLOW}${FILE_COMPOSE}${WHITE}..."
sed -i "s/{CERT_EMAIL}/$email/g" ${FILE_COMPOSE}

info "${WHITE}Replacing E-Mail placeholders with ${YELLOW}${email} ${WHITE}in ${YELLOW}${FILE_TRAEFIK}${WHITE}..."
sed -i "s/{CERT_EMAIL}/$email/g" ${FILE_TRAEFIK}

info "${WHITE}Replacing token placeholders with ${YELLOW}${token} ${WHITE}in ${YELLOW}${FILE_COMPOSE}${WHITE}..."
sed -i "s/{CF_TOKEN}/$token/g" ${FILE_COMPOSE}
#
info "${WHITE}Configuration of files ${YELLOW}${FILE_COMPOSE} & ${FILE_TRAEFIK} ${WHITE}done!"

# This part creates the nginx directories and sets up the configuration
info "${WHITE}Creating ${YELLOW}nginx directories${WHITE}..."
mkdir "./nginx/"
mkdir "./nginx/conf/"
mkdir "./nginx/log/"
mkdir "./public/"

info "${WHITE}Starting ${YELLOW}configuration ${WHITE}for the nginx files..."
docker create --name lemp_tmp1 nginx
docker start lemp_tmp1
docker cp lemp_tmp1:/etc/nginx/. ./nginx/conf/
docker stop lemp_tmp1 && docker rm lemp_tmp1
rm ./nginx/conf/conf.d/default.conf

touch ./nginx/conf/conf.d/default.conf
echo "server {" >> ./nginx/conf/conf.d/default.conf
echo "    root /var/www/html/;" >> ./nginx/conf/conf.d/default.conf
echo "    index index.php index.html;" >> ./nginx/conf/conf.d/default.conf
echo "    server_name localhost;" >> ./nginx/conf/conf.d/default.conf
echo "    error_log  /var/log/nginx/error.log;" >> ./nginx/conf/conf.d/default.conf
echo "    access_log /var/log/nginx/access.log;" >> ./nginx/conf/conf.d/default.conf
echo "" >> ./nginx/conf/conf.d/default.conf >> ./nginx/conf/conf.d/default.conf
echo "    try_files $uri $uri/ /index.php?it=$uri&$args;"
echo "" >> ./nginx/conf/conf.d/default.conf
echo '    location ~ \.php$ {' >> ./nginx/conf/conf.d/default.conf
echo '       try_files $uri =404;' >> ./nginx/conf/conf.d/default.conf
echo '       fastcgi_split_path_info ^(.+\.php)(/.+)$;' >> ./nginx/conf/conf.d/default.conf
echo "       fastcgi_pass php-cgi:9000;" >> ./nginx/conf/conf.d/default.conf
echo "       fastcgi_index index.php;" >> ./nginx/conf/conf.d/default.conf
echo "       include fastcgi_params;" >> ./nginx/conf/conf.d/default.conf
echo '       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> ./nginx/conf/conf.d/default.conf
echo '       fastcgi_param PATH_INFO $fastcgi_path_info;' >> ./nginx/conf/conf.d/default.conf
echo "    }" >> ./nginx/conf/conf.d/default.conf
echo "}" >> ./nginx/conf/conf.d/default.conf

touch ./public/index.php
echo "<?php" >> ./public/index.php
echo " phpinfo();" >> ./public/index.php
echo "?>" >> ./public/index.php

info "${WHITE}Configuration of the ${YELLOW}nginx files ${WHITE}is done!"
#

# This part creates the mariadb directories
info "${WHITE}Creating ${YELLOW}mariadb directories ${WHITE}..."
mkdir "./mariadb"
mkdir "./mariadb/conf/"
mkdir "./mariadb/lib/"
mkdir "./mariadb/log/"
mkdir "./mysql/"

docker create --name lemp_tmp1 mariadb
docker start lemp_tmp1
docker cp lemp_tmp1:/etc/mysql/. ./mariadb/conf/
docker stop lemp_tmp1 && docker rm lemp_tmp1
#

# This part asks the user for the mysql passwords and replaces the placeholders in the docker-compose.yml file
info "${WHITE}Starting ${YELLOW}mariadb ${WHITE}configuration..."

printf "${WHITE}Please enter your ${YELLOW}MySQL Root Password${WHITE}: ${YELLOW}"
read -p "" mysql_root_password
info "${WHITE}MySQL Root password ${YELLOW}***** ${WHITE}registered!"

printf "${WHITE}Please enter your ${YELLOW}MySQL Mautic Password${WHITE}: ${YELLOW}"
read -p "" mysql_mautic_password
info "${WHITE}MySQL Mautic password ${YELLOW}***** ${WHITE}registered!"

info "${WHITE}Replacing MySQL Root password placeholder with ${YELLOW}***** ${WHITE}in ${YELLOW}${FILE_COMPOSE}${WHITE}..."
sed -i "s/{MYSQL_R_PASSWORD}/$mysql_root_password/g" ${FILE_COMPOSE}

info "${WHITE}Replacing MySQL Mautic password placeholder with ${YELLOW}***** ${WHITE}in ${YELLOW}${FILE_COMPOSE}${WHITE}..."
sed -i "s/{MYSQL_MAUTIC_PASSWORD}/$mysql_mautic_password/g" ${FILE_COMPOSE}

info "${WHITE}Configuration of ${YELLOW}mariadb ${WHITE}done!"
#

# This part asks the user for the htaccess password and replaces the placeholders in the docker-compose.yml file
info "${WHITE}Starting ${YELLOW}htaccess ${WHITE}configuration..."

printf "${WHITE}Please enter your ${YELLOW}admin htaccess password${WHITE}: ${YELLOW}"
read -p "" htaccess_pw
info "${WHITE}Admin htaccess password for traefik ${YELLOW}***** ${WHITE}registered!"

info "${WHITE}Encrypting the ${YELLOW}htaccess ${WHITE}password..."
htpasswd -b -c ./.htpasswd admin ${htaccess_pw}
#

# This part sets up the Docker environment and starts all container
docker network create traefik_default
info "${WHITE}Starting ${YELLOW}reverse-proxy ${WHITE}container..."
docker-compose up -d reverse-proxy

info "${WHITE}Starting ${YELLOW}nginx & php-cgi ${WHITE}container..."
docker-compose up -d php-cgi
docker-compose up -d nginx

info "${WHITE}Starting ${YELLOW}mariadb ${WHITE}container..."
docker-compose up -d mariadb

info "${WHITE}Starting ${YELLOW}phpmyadmin ${WHITE}container..."
docker-compose up -d phpmyadmin

info "${WHITE}Starting ${YELLOW}mautic ${WHITE}container..."
docker-compose up -d mautic
#

# This parts sets up the robots.txt files for pma & mautic
info "${WHITE}Setting up robots.txt files for pma & mautic"

touch robots.txt
echo "User-Agent: *" >> ./robots.txt
echo "Disallow: /" >> ./robots.txt

docker cp ./robots.txt lemp_pma:/var/www/html/
docker-compose restart
cp ./robots.txt ./mautic/web/
#

info "${WHITE}Installation of ${YELLOW}lemp-stack ${WHITE}done!"
