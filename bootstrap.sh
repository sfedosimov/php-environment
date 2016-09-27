#!/usr/bin/env bash

HTTP_PATH="/var/www/html"

# Edit PS1
echo "####################################################################"
echo "############################# Edit PS1 #############################"
echo "####################################################################"
echo '
PS1="\[\033[38;5;130m\]\u\[$(tput sgr0)\]\[\033[38;5;22m\]@\[$(tput sgr0)\]\[\033[38;5;130m\]\h\[$(tput sgr0)\]\[\033[38;5;94m\]:\[$(tput sgr0)\]\[\033[38;5;24m\][\w]:\[$(tput sgr0)\]\[\033[38;5;8m\] \[$(tput sgr0)\]"
' >> /home/vagrant/.bashrc

# set php 5.6 ppa
echo "####################################################################"
echo "######################## SET PHP 5.6 PPA ###########################"
echo "####################################################################"
apt-get install -y python-software-properties
add-apt-repository -y ppa:ondrej/php5-5.6

# updates
echo "####################################################################"
echo "########################## UPDATING APT ############################"
echo "####################################################################"
apt-get update

# Install Apache
echo "####################################################################"
echo "####################### INSTALLING APACHE ##########################"
echo "####################################################################"
apt-get -y install apache2

# Config Apache ssl
echo "####################################################################"
echo "######################### CONFIG APACHE SSL ########################"
echo "####################################################################"
a2enmod ssl
mkdir /etc/apache2/ssl
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.site.dev" -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

# enable modrewrite
echo "####################################################################"
echo "##################### ENABLING APACHE MOD-REWRITE ##################"
echo "####################################################################"
a2enmod rewrite

# ServerName
echo "####################################################################"
echo "######################### APACHE ServerName ########################"
echo "####################################################################"
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# dos2unix characters fix for install from windows
echo "####################################################################"
echo "########################### DOS2UNIX ###############################"
echo "####################################################################"
apt-get -y install dos2unix

# install tools
echo "####################################################################"
echo "############################ TOOLS #################################"
echo "####################################################################"
dos2unix ${HTTP_PATH}/sitemanager.sh
dos2unix ${HTTP_PATH}/backup.sh
mv ${HTTP_PATH}/sitemanager.sh /usr/local/bin/site-manager
mv ${HTTP_PATH}/backup.sh /usr/local/bin/site-backuper

# Creating and configuring vhost
echo "####################################################################"
echo "############################ VHOST #################################"
echo "####################################################################"
site-manager -c site

# Setting Locales
echo "####################################################################"
echo "######################## Setting Locales ###########################"
echo "####################################################################"
locale-gen en_US en_US.UTF-8 ru_RU ru_RU.UTF-8
dpkg-reconfigure locales

# Install MySQL 5.6
echo "####################################################################"
echo "######################## INSTALLING MYSQL ##########################"
echo "####################################################################"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server-5.6 mysql-client-5.6

# Config mysql
echo "####################################################################"
echo "######################### CONFIGURE MYSQL ##########################"
echo "####################################################################"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "wait_timeout = 600" >> /etc/mysql/my.cnf

# Create Database instance and global root user
echo "####################################################################"
echo "############## CREATING DATABASE & ADD % TO ROOT ###################"
echo "####################################################################"
mysql -u root -e "create database site;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '';"
service mysql restart

# Install PHP 5.6
echo "####################################################################"
echo "########################## INSTALLING PHP ##########################"
echo "####################################################################"
apt-get -y install php5

# Config php
echo "####################################################################"
echo "########################## CONFIGURE PHP ###########################"
echo "####################################################################"
echo "memory_limit = 1024M" >> /etc/php5/apache2/php.ini
echo "max_execution_time = 600" >> /etc/php5/apache2/php.ini
echo "always_populate_raw_post_data = -1" >> /etc/php5/apache2/php.ini

# Install Required PHP extensions
echo "####################################################################"
echo "###################### INSTALLING PHP EXTENSIONS ###################"
echo "####################################################################"
apt-get -y install php5-mhash php5-mcrypt php5-curl php5-cli php5-mysqlnd php5-gd php5-intl php5-common php-pear php5-dev php5-xsl php5-xdebug

# Mcrypt issue
echo "####################################################################"
echo "########################## PHP MYCRYPT PATCH #######################"
echo "####################################################################"
php5enmod mcrypt
service apache2 restart

# Set PHP Timezone
echo "####################################################################"
echo "############################ PHP TIMEZONE ##########################"
echo "####################################################################"
echo "date.timezone = America/New_York" >> /etc/php5/cli/php.ini

# Set Pecl php_ini location
echo "####################################################################"
echo "########################### CONFIGURE PECL #########################"
echo "####################################################################"
pear config-set php_ini /etc/php5/apache2/php.ini

# Config xdebug
echo "####################################################################"
echo "######################### CONFIGURE XDEBUG #########################"
echo "####################################################################"
echo "xdebug.remote_enable = 1" >> /etc/php5/apache2/php.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/apache2/php.ini

# Install Git
echo "####################################################################"
echo "########################## INSTALLING GIT ##########################"
echo "####################################################################"
apt-get -y install git

# Composer Installation
echo "####################################################################"
echo "####################### INSTALLING COMPOSER ########################"
echo "####################################################################"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Pfostfix Installation
echo "####################################################################"
echo "######################## INSTALLING POSTFIX ########################"
echo "####################################################################"
debconf-set-selections <<< "postfix postfix/mailname string site.dev"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get -y install postfix

# Set Ownership and Permissions
echo "####################################################################"
echo "################## SETTING OWNERSHIP AND PERMISSIONS ###############"
echo "####################################################################"
chown -R www-data ${HTTP_PATH}/site/
find ${HTTP_PATH}/site/ -type d -exec chmod 700 {} \;
find ${HTTP_PATH}/site/ -type f -exec chmod 600 {} \;

# Restart apache
echo "####################################################################"
echo "######################### RESTARTING APACHE ########################"
echo "####################################################################"
service apache2 restart

# install other soft
echo "####################################################################"
echo "######################## INSTALL OTHER SOFT ########################"
echo "####################################################################"
apt-get -y install htop

# Post Up Message
echo "####################################################################"
echo "####################################################################"
echo "################# PHP-Environment Vagrant Box ready! ###############"
echo "################# Go to http://192.168.99.99/site/   ###############"
echo "####################################################################"
echo "####################################################################"
