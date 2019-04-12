# Nextcloud
CREATE DATABASE Nextcloud;
CREATE USER 'nextcloud'@'192.168.0.20' IDENTIFIED BY 'etO0h5;+(KJz}/RP?5E';
GRANT ALL PRIVILEGES ON Nextcloud.* TO 'nextcloud'@'192.168.0.20';

# GitLab
CREATE DATABASE GitLab;
CREATE USER 'gitlab'@'192.168.0.30' IDENTIFIED BY 'c&,a\r|>D@OpFQF%n~cu';
GRANT ALL PRIVILEGES ON Gitlab.* TO 'gitlab'@'192.168.0.30';
