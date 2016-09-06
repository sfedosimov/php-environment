#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Please run as root"
    exit
fi

if [ -z "$1" ]; then
    echo "Please pass an action"
    exit
fi

if [ -z "$2" ]; then
    echo "Please pass site name"
    exit
fi

if [ "$1" = "-c" ]; then
    mkdir /var/www/html/$2
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
elif [ "$1" = "-d" ]; then
    read -p "Are you sure? [y/n]" -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        a2dissite $2.conf
        rm -f /etc/apache2/sites-available/$2.conf
        rm -rf /var/www/html/$2
    fi
    echo "success!"
    echo # (optional) move to a new line
fi
