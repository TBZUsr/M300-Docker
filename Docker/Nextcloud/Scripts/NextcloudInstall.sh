
#!/bin/bash

# Install apache2 and PHP 7
apt-get update
apt-get install sudo wget apache2 libapache2-mod-php7.2 -y
apt-get install php7.2-gd php7.2-json php7.2-pgsql php7.2-curl php7.2-mbstring -y
apt-get install php7.2-intl php-imagick php7.2-xml php7.2-zip -y


# Download and extract nextcloud
cd /var/www/html
# Empty the directory
rm -r -f *
# Get nextcloud
wget https://download.nextcloud.com/server/releases/nextcloud-15.0.5.tar.bz2 -O nextcloud.tar.bz2
tar -xjf nextcloud.tar.bz2

mv nextcloud/* ./

# Remove unnecessary files
rm -f -r nextcloud.tar.bz2
rm -f -r nextcloud

# Set the rights
chown -R www-data:www-data /var/www/html
chmod 750 /var/www/html -R

# Create a data folder an set the rights
mkdir /Nextcloud
chown www-data:www-data /Nextcloud
chmod 750 /Nextcloud

# Create a backup
mkdir /Backup
cp -r /var/www/html/* /Backup

# Generate ssl cert
mkdir /etc/apache2/ssl
openssl req -x509 -newkey rsa:4096 -nodes -days 730 -keyout /etc/apache2/ssl/ssl.key -out /etc/apache2/ssl/ssl.crt -subj "/C=CH/ST=Zurich/L=Switzerland/O=TBZ/CN=192.168.10.66"

# Set the nextcloud apache2 configs
echo "

<Directory /var/www/html/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/html
 SetEnv HTTP_HOME /var/www/html

</Directory>" > "/etc/apache2/sites-available/nextcloud.conf"

# Set the ssl configs
echo "
<VirtualHost *:443>
  DocumentRoot /var/www/html
  SSLEngine on
  SSLCertificateFile /etc/apache2/ssl/ssl.crt
  SSLCertificateKeyFile /etc/apache2/ssl/ssl.key
</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf

# Enable the nextcloud apache2 configs
a2ensite nextcloud.conf

# Enable the ssl mode
a2enmod ssl

# Reload the apache2 server
service apache2 restart
