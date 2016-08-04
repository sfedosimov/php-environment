#!/usr/bin/env bash

# This script can be used to perform any sort of command line actions to setup your box.
# This includes installing software, importing databases, enabling new sites, pulling from
# remote servers, etc.

# Edit PS1
echo "########################"
echo "####### Edit PS1 #######"
echo "########################"
echo '
PS1="\[\033[38;5;130m\]\u\[$(tput sgr0)\]\[\033[38;5;22m\]@\[$(tput sgr0)\]\[\033[38;5;130m\]\h\[$(tput sgr0)\]\[\033[38;5;94m\]:\[$(tput sgr0)\]\[\033[38;5;24m\][\w]:\[$(tput sgr0)\]\[\033[38;5;8m\] \[$(tput sgr0)\]"
' >> /home/vagrant/.bashrc

# set php 5.6 ppa
echo "###########################"
echo "##### SET PHP 5.6 PPA #####"
echo "###########################"
apt-get install -y python-software-properties
add-apt-repository -y ppa:ondrej/php5-5.6

# updates
echo "########################"
echo "##### UPDATING APT #####"
echo "########################"
apt-get update

# Install Apache
echo "#############################"
echo "##### INSTALLING APACHE #####"
echo "#############################"
apt-get -y install apache2

# Creating folder
echo "#######################################"
echo "####### SITE FOLDER PERMISSIONS #######"
echo "#######################################"
chmod 0777 -R /var/www/html/site

# enable modrewrite
echo "#######################################"
echo "##### ENABLING APACHE MOD-REWRITE #####"
echo "#######################################"
a2enmod rewrite

# append AllowOverride to Apache Config File
echo "#######################################"
echo "##### CREATING APACHE CONFIG FILE #####"
echo "#######################################"
echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/site
		ServerName site.dev
		ServerAlias www.site.dev

		<Directory '/var/www/html/site'>
			Options Indexes FollowSymLinks MultiViews
			AllowOverride All
			Order allow,deny
			allow from all
		</Directory>
</VirtualHost>
" > /etc/apache2/sites-available/site.conf

echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enabling Site
echo "##################################"
echo "######### Enabling Site ##########"
echo "##################################"
a2ensite site.conf

# Setting Locales
echo "###########################"
echo "##### Setting Locales #####"
echo "###########################"
locale-gen en_US en_US.UTF-8 ru_RU ru_RU.UTF-8
dpkg-reconfigure locales

# Install MySQL 5.6
echo "############################"
echo "##### INSTALLING MYSQL #####"
echo "############################"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server-5.6 mysql-client-5.6

# Create Database instance
echo "#############################"
echo "##### CREATING DATABASE #####"
echo "#############################"
mysql -u root -e "create database site;"

# Install PHP 5.5
echo "##########################"
echo "##### INSTALLING PHP #####"
echo "##########################"
apt-get -y install php5

# Install Required PHP extensions
echo "#####################################"
echo "##### INSTALLING PHP EXTENSIONS #####"
echo "#####################################"
apt-get -y install php5-mhash php5-mcrypt php5-curl php5-cli php5-mysqlnd php5-gd php5-intl php5-common php-pear php5-dev php5-xsl

# Mcrypt issue
echo "#############################"
echo "##### PHP MYCRYPT PATCH #####"
echo "#############################"
php5enmod mcrypt
service apache2 restart

# Set PHP Timezone
echo "########################"
echo "##### PHP TIMEZONE #####"
echo "########################"
echo "date.timezone = America/New_York" >> /etc/php5/cli/php.ini

# Set Pecl php_ini location
echo "##########################"
echo "##### CONFIGURE PECL #####"
echo "##########################"
pear config-set php_ini /etc/php5/apache2/php.ini

# Install Xdebug
echo "##########################"
echo "##### INSTALL XDEBUG #####"
echo "##########################"
pecl install xdebug

# Install Pecl Config variables
echo "############################"
echo "##### CONFIGURE XDEBUG #####"
echo "############################"
echo "xdebug.remote_enable = 1" >> /etc/php5/apache2/php.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/apache2/php.ini

# Install Git
echo "##########################"
echo "##### INSTALLING GIT #####"
echo "##########################"
apt-get -y install git

# Composer Installation
echo "###############################"
echo "##### INSTALLING COMPOSER #####"
echo "###############################"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Pfostfix Installation
echo "###############################"
echo "##### INSTALLING POSTFIX ######"
echo "###############################"
debconf-set-selections <<< "postfix postfix/mailname string site.dev"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y postfix

# Set Ownership and Permissions
echo "#############################################"
echo "##### SETTING OWNERSHIP AND PERMISSIONS #####"
echo "#############################################"
chown -R www-data /var/www/html/site/
find /var/www/html/site/ -type d -exec chmod 700 {} \;
find /var/www/html/site/ -type f -exec chmod 600 {} \;

# Restart apache
echo "#############################"
echo "##### RESTARTING APACHE #####"
echo "#############################"
service apache2 restart

# Post Up Message
echo "PHP-Environment Vagrant Box ready!"
echo "Go to http://192.168.99.99/site/"
