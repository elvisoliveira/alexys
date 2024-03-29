FROM php:7-apache
MAINTAINER Elvis Oliveira <elvis.olv@gmail.com>

# Project Dependencies
WORKDIR /var/www/alexys

# Enviroment Dependencies:
# Composer requires zip and git. (https://getcomposer.org/doc/00-intro.md#system-requirements)
RUN apt-get update && \
    apt-get install gnupg wget curl -y
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get update && \
    apt-get install git unzip build-essential nodejs mysql-client libpng-dev libjpeg-dev ruby ruby-dev -y && \
    docker-php-ext-install mysqli

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# PHP Extensions
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install mysqli gd

# Some required Node.js packages expects 
# nodejs command to be node.
# RUN ln -s /usr/bin/nodejs /usr/bin/node

# Node.js 
RUN npm install -g yarn grunt grunt-cli

# Ruby Extensions
RUN gem install sass

# PHP / Apache Conf.
COPY ./.docker/webserver/php.ini ${PHP_INI_DIR}/php.ini
COPY ./.docker/webserver/apache2.conf ${APACHE_CONFDIR}/apache2.inc.conf
COPY ./.docker/webserver/000-default.conf ${APACHE_CONFDIR}/sites-available/000-default.conf

RUN echo "include apache2.inc.conf" >> /etc/apache2/apache2.conf

RUN a2enmod rewrite && \
    apache2ctl restart

# Exec.
EXPOSE 80