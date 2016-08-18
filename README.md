# Vagrant for PHP-Environment

## Prerequisites
### Virtualbox
[VirtualBox](https://www.virtualbox.org/) is an open source virtualizer, an application that can run an entire operating system within its own virtual machine. 

1. Download the installer for your laptop operating system using the links below.
    * [VirtualBox for Windows Hosts](http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-Win.exe)
    * [VirtualBox for OS X hosts](http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg)
    * [VirtualBox for Linux hosts](https://www.virtualbox.org/wiki/Linux_Downloads) (requires that you pick your distro)
1. Run the installer, choosing all of the default options.
    * Windows: Grant the installer access every time you receive a security prompt.
    * Mac: Enter your admin password.
    * Linux: Enter your root password if prompted.
1. Reboot your laptop if prompted to do so when installation completes.
1. Close the VirtualBox window if it pops up at the end of the install.

### Vagrant
[Vagrant](https://www.vagrantup.com/) is an open source command line utility for managing reproducible developer environments. 

1. Download the installer for your laptop operating system using the links below.
    * [Vagrant for Windows hosts](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5.msi)
    * [Vagrant for OS X hosts](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5.dmg)
    * [Vagrant for Linux hosts](https://www.vagrantup.com/downloads.html) (requires that you pick your distro)
1. Run the installer, choosing all defaults.
1. Reboot your laptop if prompted to do so when installation completes.

## Usage
After Vagrant and Virtualbox are setup, run the following commands to install the Dev Box. 

**Clone the Repository**

    git clone https://github.com/sfedosimov/php-environment.git
**Navigate to the folder**

    cd /path/to/project/

**Run Vagrant Command**

    vagrant up

**Other Info**

    Database Username: root
    Database Password: (none)
    Database Name: site
    Host File Configuration: 192.168.99.99 www.site.dev site.dev
    URL of Instance: http://site.dev/
    
**Scripts**

    # create new vhost and folder for it
    sudo sh /var/www/html/sitemanager.sh -c newsite
    
    # delete vhost and folder for it
    sudo sh /var/www/html/sitemanager.sh -d newsite

**Installed soft**

PHP 5.6:

 + php5-mcrypt
 + php5-curl
 + php5-cli
 + php5-mysqlnd
 + php5-gd
 + php5-intl
 + php5-common
 + php-pear
 + php5-dev
 + php5-xsl

PECL:

 + xdebug
 
 
MYSQL 5.6

APACHE 2.4 (with ssl

POSTFIX 2.11

HTOP