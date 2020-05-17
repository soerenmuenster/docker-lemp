#!/bin/bash

echo "Creating directories..."
mkdir "./letsencrypt/"
mkdir "./nginx_reverse/"
mkdir "./nginx_reverse/conf/"
mkdir "./nginx_reverse/log/"
mkdir "./portainer/"
mkdir "./public/"
mkdir "./nginx_web/"
mkdir "./nginx_web/conf/"
mkdir "./nginx_web/log/"
mkdir "./mariadb/"
mkdir "./mariadb/conf/"
mkdir "./mariadb/lib/"
mkdir "./mariadb/log/"
mkdir "./mysql/"

read -p "Enter your URL: " url
echo ""
read -p "Enter your E-Mail (for the SSL-Certificate): " email
echo ""
read -p "Enter your cloudflare API-Token: " token
echo ""

echo "Edit docker-compose.yml..."
echo "	Replace URL..."
sed -i "s/{URL}/$url/g" docker-compose.yml 
echo "	Replace E-Mail..."
sed -i "s/{EMAIL}/$email/g" docker-compose.yml
echo ""

echo "Starting LetsEncrypt Container..."
docker-compose up -d letsencrypt

echo "LetsEncrypt initializes the DM parameters. This can take a while, so please dont stop the script..."
FILE_KEY=./letsencrypt/etc/letsencrypt/keys/0000_key-certbot.pem
while [ ! -f "$FILE_KEY" ];
do
	sleep 15s
	echo "..."
done;
docker-compose down
echo "Initialization of the DM parameters is done. Edit DNS-Conf cloudflare.ini..."
sed -i "s/dns_cloudflare_email = cloudflare@example.com//g" ./letsencrypt/dns-conf/cloudflare.ini
sed -i "s/dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234567//g" ./letsencrypt/dns-conf/cloudflare.ini
sed -i "s/#dns_cloudflare_api_token = 0123456789abcdef0123456789abcdef01234567/dns_cloudflare_api_token = $token/g" ./letsencrypt/dns-conf/cloudflare.ini
echo "Configuration of the cloudflare.ini is done."
docker-compose up -d letsencrypt
echo "LetsEncrypt initializes the certificates. This can take also a while, so please dont stop the script..."
FILE_CERTIFICATE="./letsencrypt/etc/letsencrypt/archive/$url/fullchain1.pem"
while [ ! -f "$FILE_CERTIFICATE" ];
do
	sleep 15s
	echo "..."
done;
echo "Initialization of the certificates is done. Download nginx default configurations..."
docker create --name lemp_tmp1 nginx
docker start lemp_tmp1
docker cp lemp_tmp1:/etc/nginx/. ./nginx_reverse/conf/
docker stop lemp_tmp1 && docker rm lemp_tmp1
echo "Download of nginx default configurations is done."

read -p "Enter your IPv4 address for the reverse-proxy: " ipv4
echo "Edit reverse-proxy configurations..."
rm ./nginx_reverse/conf/conf.d/default.conf

touch ./nginx_reverse/conf/conf.d/portainer.conf
echo "upstream portainer {" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "  server        localhost:9000;" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "}" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "server {" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "  listen        443 ssl;" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "  server_name   portainer.$url;" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "" >> ./nginx_reverse/conf/conf.d/portainer.conf
echo '  auth_basic "Restricted";' >> ./nginx_reverse/conf/conf.d/portainer.conf
echo '  auth_basic_user_file /etc/nginx/.htpasswd;' >> ./nginx_reverse/conf/conf.d/portainer.conf
echo "" >> ./nginx_reverse/conf/conf.d/portainer.conf
echo "  include       common.conf;" >> ./nginx_reverse/conf/conf.d/portainer.conf
echo "  include       /etc/nginx/ssl.conf;" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "  location / {" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "    proxy_pass  http://$ipv4:9000;" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "  }" >> ./nginx_reverse/conf/conf.d/portainer.conf 
echo "}" >> ./nginx_reverse/conf/conf.d/portainer.conf 

touch ./nginx_reverse/conf/conf.d/pma.conf
echo "upstream pma {" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  server        localhost:8070;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "}" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "server {" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  listen        443 ssl;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  server_name   pma.$url;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "" >> ./nginx_reverse/conf/conf.d/pma.conf
echo '  auth_basic "Restricted";' >> ./nginx_reverse/conf/conf.d/pma.conf
echo '  auth_basic_user_file /etc/nginx/.htpasswd;' >> ./nginx_reverse/conf/conf.d/pma.conf
echo "" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  include       common.conf;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  include       /etc/nginx/ssl.conf;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  location / {" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "    proxy_pass  http://$ipv4:8070;" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "  }" >> ./nginx_reverse/conf/conf.d/pma.conf
echo "}" >> ./nginx_reverse/conf/conf.d/pma.conf

touch ./nginx_reverse/conf/conf.d/default.conf
echo "upstream default {" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  server        localhost:8080;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "}" >> ./nginx_reverse/conf/conf.d/default.conf
echo "" >> ./nginx_reverse/conf/conf.d/default.conf
echo "server {" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  listen        443 ssl;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  server_name   $url;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  include       common.conf;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  include       /etc/nginx/ssl.conf;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  location / {" >> ./nginx_reverse/conf/conf.d/default.conf
echo "    proxy_pass  http://$ipv4:8080;" >> ./nginx_reverse/conf/conf.d/default.conf
echo "  }" >> ./nginx_reverse/conf/conf.d/default.conf
echo "}" >> ./nginx_reverse/conf/conf.d/default.conf

touch ./nginx_reverse/conf/conf.d/redirect.conf
echo "server {" >> ./nginx_reverse/conf/conf.d/redirect.conf
echo "  listen        80;" >> ./nginx_reverse/conf/conf.d/redirect.conf
echo "" >> ./nginx_reverse/conf/conf.d/redirect.conf
echo "  server_name   _;" >> ./nginx_reverse/conf/conf.d/redirect.conf
echo "" >> ./nginx_reverse/conf/conf.d/redirect.conf
echo '  return 301 https://$host$request_uri;' >> ./nginx_reverse/conf/conf.d/redirect.conf
echo "}" >> ./nginx_reverse/conf/conf.d/redirect.conf

touch ./nginx_reverse/conf/common.conf
echo 'add_header Strict-Transport-Security    "max-age=31536000; includeSubDomains" always;' >> ./nginx_reverse/conf/common.conf
echo "add_header X-Frame-Options              SAMEORIGIN;" >> ./nginx_reverse/conf/common.conf
echo "add_header X-Content-Type-Options       nosniff;" >> ./nginx_reverse/conf/common.conf
echo 'add_header X-XSS-Protection             "1; mode=block";' >> ./nginx_reverse/conf/common.conf

touch ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    X-Real-IP           $remote_addr;' >> ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;' >> ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    X-Forwarded-Proto   $scheme;' >> ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    Host                $host;' >> ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    X-Forwarded-Host    $host;' >> ./nginx_reverse/conf/common_location.conf
echo 'proxy_set_header    X-Forwarded-Port    $server_port;' >> ./nginx_reverse/conf/common_location.conf

touch ./nginx_reverse/conf/ssl.conf
echo "ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_ecdh_curve              secp384r1;" >> ./nginx_reverse/conf/ssl.conf
echo 'ssl_ciphers                 "ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384 OLD_TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256 OLD_TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256";' >> ./nginx_reverse/conf/ssl.conf
echo "ssl_prefer_server_ciphers   on;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_dhparam                 /etc/nginx/dhparams.pem;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_certificate             /etc/ssl/private/fullchain1.pem;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_certificate_key         /etc/ssl/private/privkey1.pem;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_session_timeout         10m;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_session_cache           shared:SSL:10m;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_session_tickets         off;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_stapling                on;" >> ./nginx_reverse/conf/ssl.conf
echo "ssl_stapling_verify         on;" >> ./nginx_reverse/conf/ssl.conf
apt-get install apache2-utils
htpasswd -c ./nginx_reverse/conf/.htpasswd admin

FILE_DHPARAMS=./nginx_reverse/conf/dhparams.pem
echo "Configuration of the reverse-proxy is done. Initializing new DH parameters. This can also take a while, so please dont stop the script..."
if [ ! -f "$FILE_DHPARAMS" ]; then
   openssl dhparam -out $FILE_DHPARAMS 4096
fi
echo "Initialization of new DH parameters is done. Starting nginx_reverse container..."
docker-compose up -d nginx

echo "Starting Portainer container..."
docker-compose up -d portainer

echo "Download nginx default configuration..."
docker create --name lemp_tmp1 nginx
docker start lemp_tmp1
docker cp lemp_tmp1:/etc/nginx/. ./nginx_web/conf/
docker stop lemp_tmp1 && docker rm lemp_tmp1
echo "Download of nginx default configurations is done."

echo "Edit nginx web server configuration..."
rm ./nginx_web/conf/conf.d/default.conf
touch ./nginx_web/conf/conf.d/default.conf
echo "server {" >> ./nginx_web/conf/conf.d/default.conf
echo "    root /var/www/;" >> ./nginx_web/conf/conf.d/default.conf
echo "    index index.php index.html;" >> ./nginx_web/conf/conf.d/default.conf
echo "    server_name localhost;" >> ./nginx_web/conf/conf.d/default.conf
echo "    error_log  /var/log/nginx/error.log;" >> ./nginx_web/conf/conf.d/default.conf
echo "    access_log /var/log/nginx/access.log;" >> ./nginx_web/conf/conf.d/default.conf
echo "" >> ./nginx_web/conf/conf.d/default.conf
echo '    location ~ \.php$ {' >> ./nginx_web/conf/conf.d/default.conf
echo '       try_files $uri =404;' >> ./nginx_web/conf/conf.d/default.conf
echo '       fastcgi_split_path_info ^(.+\.php)(/.+)$;' >> ./nginx_web/conf/conf.d/default.conf
echo "       fastcgi_pass php-cgi:9000;" >> ./nginx_web/conf/conf.d/default.conf
echo "       fastcgi_index index.php;" >> ./nginx_web/conf/conf.d/default.conf
echo "       include fastcgi_params;" >> ./nginx_web/conf/conf.d/default.conf
echo '       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> ./nginx_web/conf/conf.d/default.conf
echo '       fastcgi_param PATH_INFO $fastcgi_path_info;' >> ./nginx_web/conf/conf.d/default.conf
echo "    }" >> ./nginx_web/conf/conf.d/default.conf
echo "}" >> ./nginx_web/conf/conf.d/default.conf
echo "Configuration of the nginx web-server is done. Starting nginx web-server container..."
docker-compose up -d nginx_web

echo "Download mariadb default configuration..."
docker create --name lemp_tmp1 mariadb
docker start lemp_tmp1
docker cp lemp_tmp1:/etc/mysql/. ./mariadb/conf/
docker stop lemp_tmp1 && docker rm lemp_tmp1
echo "Download of mariadb default configuration is done. Starting mariadb container..."
docker-compose up -d mariadb
echo "Starting PhpMyAdmin container..."
docker-compose up -d phpmyadmin
echo "Installation done!"