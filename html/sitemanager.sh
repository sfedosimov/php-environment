#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
    echo "Please run as root"
    exit
fi

if [ -z "$1" ]; then
    printf "./sitemanager.sh -c site\n./sitemanager.sh -d site --with-db\n\n\t -c \t create \n \t -d \t delete \n \t --with-db \t delete site with it db\n\n"
    exit
fi

if [ -z "$2" ]; then
    echo "Please pass site name"
    exit
fi

if [ "$1" = "-c" ]; then

    if [[ -e "$2" ]]; then
        echo "Directory $2 already exist!"
        exit
    fi

    mkdir /var/www/html/$2

    if [[ -e "/etc/apache2/sites-available/$2.conf" ]]; then
        echo "VHost /etc/apache2/sites-available/$2.conf already exist!"
        exit
    fi

    echo "
        <VirtualHost *:80>
            ServerAdmin webmaster@localhost
            DocumentRoot /var/www/html/$2
            ServerName $2.dev
            ServerAlias www.$2.dev

            LogLevel notice
            ErrorLog \${APACHE_LOG_DIR}/error-$2.dev.log

            LogFormat \"%l %t \\\"%r\\\" %>s %b %D\" common
            CustomLog \${APACHE_LOG_DIR}/access-$2.dev.log common

            <Directory '/var/www/html/$2'>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
                # magento config
                # SetEnvIf Host ^$2\.dev$ MAGE_RUN_CODE=$2
                SetEnv MAGE_IS_DEVELOPER_MODE \"true\"
            </Directory>
        </VirtualHost>

        <IfModule mod_ssl.c>
            <VirtualHost *:443>
                ServerAdmin webmaster@localhost
                ServerName $2.dev
                ServerAlias www.$2.dev

                LogLevel notice
                ErrorLog \${APACHE_LOG_DIR}/error-$2.dev.log

                LogFormat \"%l %t \\\"%r\\\" %>s %b %D\" common
                CustomLog \${APACHE_LOG_DIR}/access-$2.dev.log common

                DocumentRoot /var/www/html/$2

                SSLEngine on
                SSLCertificateFile /etc/apache2/ssl/apache.crt
                SSLCertificateKeyFile /etc/apache2/ssl/apache.key

                <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
                        SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory '/var/www/html/$2'>
                    Options Indexes FollowSymLinks MultiViews
                    AllowOverride All
                    Order allow,deny
                    allow from all
                    # magento config
                    # SetEnvIf Host ^$2\.dev$ MAGE_RUN_CODE=$2
                    SetEnv MAGE_IS_DEVELOPER_MODE \"true\"
                </Directory>
                BrowserMatch \"MSIE [2-6]\" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
                BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown
            </VirtualHost>
        </IfModule>
    " > /etc/apache2/sites-available/$2.conf
    a2ensite $2.conf
    mysql -u root -e "create database $2;"
elif [ "$1" = "-d" ]; then
    read -p "Are you sure: delete all item of the \"$2\"? [y/n]" -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        a2dissite $2.conf
        rm -f /etc/apache2/sites-available/$2.conf
        rm -rf /var/www/html/$2

        if [[ "$3" = "--with-db" ]]
        then
            mysql -u root -e "drop database $2;"
        fi
    fi
    echo "success!"
    echo # (optional) move to a new line
fi
