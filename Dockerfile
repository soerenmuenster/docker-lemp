FROM php:apache

RUN apt-get update && apt-get install -y \
        libicu-dev \
     && docker-php-ext-install \
         intl \
     && docker-php-ext-enable \
         intl
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN apt-get update -y && apt-get install -y libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \
    libfreetype6-dev
RUN apt-get update && \
    apt-get install -y \
     zlib1g-dev

RUN apt-get install -y libzip-dev
RUN docker-php-ext-install zip

RUN docker-php-ext-install gd

SHELL ["/bin/bash", "-c"]
RUN ln -s ../mods-available/{expires,headers,rewrite}.load /etc/apache2/mods-enabled/
RUN sed -e '/<Directory \/var\/www\/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf

