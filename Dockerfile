FROM ubuntu:14.04

MAINTAINER Rafael Nascimento <rafaeln.dev@gmail.com>

#teste
RUN apt-get update
RUN apt-get -y upgrade

# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl php5-dev curl
RUN apt-get -y install git
RUN apt-get -y install php5-xmlrpc php5-mcrypt
RUN apt-get autoclean
RUN apt-get autoremove

# RUN apk update
# RUN apk add --update php-apache2 curl php5-cli php5-json php5-phar php5-openssl php5-mysql php5-gd php5-pear php5-apc php5-curl php5-dev php5-xmlrpc php5-mcrypt git vim && rm -f /var/cache/apk/* && \
RUN php5enmod mcrypt
RUN a2enmod php5
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache.pid

# Install XDEBUG
RUN pecl install xdebug
# Expose xdebug port
EXPOSE 9000

# Expose apache port
EXPOSE 80
RUN usermod -u 1000 www-data

# Copy site into place.
#ADD laravel /var/www/site

# Update the default apache site with the config we created.
#ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default, simply start apache.
# Simple startup script to avoid some issues observed with container restart
COPY run-apache.sh /usr/local/bin/run-apache.sh
RUN chmod -v +x /usr/local/bin/run-apache.sh
CMD ["/usr/local/bin/run-apache.sh"]
# CMD /usr/sbin/apache2ctl -D FOREGROUND -k restart

# Change Timezone
RUN echo 'America/Bahia' | sudo tee /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  composer global require "laravel/installer=~1.1"

ENV PATH ~/.composer/vendor/bin:$PATH

RUN mkdir /opt/moodle
