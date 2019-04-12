#!/bin/bash

# Nextcloud database
psql --user=root -c "CREATE DATABASE nextcloud;"
# Nextcloud user and privileges
psql --user=root -c "CREATE USER nextcloud WITH ENCRYPTED PASSWORD 'KkJyCtwdfjjlAvd-hdPn';
GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;"

# GitLab database
psql --user=root -c "CREATE DATABASE gitlab ENCODING 'UNICODE';"
# GitLab user and privileges
psql --user=root -c "CREATE USER gitlab WITH ENCRYPTED PASSWORD 'oIwhR58Z0spnnez0Ouhj';
GRANT ALL PRIVILEGES ON DATABASE gitlab TO gitlab;"

# Activate pg_trgm extension on GitLab database
psql --user=root -d gitlab -c "CREATE EXTENSION pg_trgm;"
