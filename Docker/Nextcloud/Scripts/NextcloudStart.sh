
#!/bin/bash

# Wait for database
sleep 10

# Static vars
NextCloudConfigDir="/Nextcloud"
NextcloudPreconfigured=false

# Check if configurations are present
if find "$NextCloudConfigDir" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    NextcloudPreconfigured=true
fi


if ! $NextcloudPreconfigured ; then
    # Restore the backup
    mv /Backup/* /var/www/html

    # Set rights
    chown www-data:www-data /var/www/html -R
    chmod 750 /var/www/html -R
    chown www-data:www-data /Nextcloud -R
    chmod 760 /Nextcloud -R

    # Configure nextcloud service
    sudo -u www-data php /var/www/html/occ maintenance:install --database "pgsql" --database-name "nextcloud" --database-user "nextcloud" --database-pass "KkJyCtwdfjjlAvd-hdPn" --database-host 192.168.0.10 --admin-user "admin" --admin-pass "Test1234" --data-dir "/Nextcloud"
    sudo -u www-data php /var/www/html/occ config:system:set trusted_domains 2 --value=192.168.10.66
fi

#service apache2 stop
/usr/sbin/apache2ctl -DFOREGROUND
