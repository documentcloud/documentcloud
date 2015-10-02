#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -e

# Requirest two arguments to be passed in.  First is environment, second is database password.
USERNAME=ubuntu
CLI_ARG=$1
PASSWORD_ARG=$2
RAILS_ENVIRONMENT=${CLI_ARG:-"$RAILS_ENV"} 
# If environment is not set exit script.  Make Command line priority.
if [ ! -n "$RAILS_ENVIRONMENT" ]; then 
  echo "environment must be set in RAILS_ENV or passed as first argument. CLI will be priority" >&2; exit 1;
fi

if [ ! -n "$PASSWORD_ARG" ]; then 
  echo "database password must passed as second argument." >&2; exit 1;
fi

echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

PACKAGES='
postgresql-9.4
postgresql-client-9.4
postgresql-contrib-9.4
'
echo $PACKAGES | xargs apt-get install -y

## setup dummy postgres environment so that you can verify rails is working
cp /etc/postgresql/9.4/main/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.default.conf
cp /home/$USERNAME/documentcloud/config/server/files/postgres/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
cp /etc/postgresql/9.4/main/postgresql.conf /etc/postgresql/9.4/main/postgresql.default.conf
cp /home/$USERNAME/documentcloud/config/server/files/postgres/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf
/etc/init.d/postgresql reload
sudo -u postgres createuser -s ubuntu
sudo -u postgres createuser -s documentcloud
sudo -u postgres psql -c "alter user documentcloud password '$PASSWORD_ARG' "
#TODO validate that this is unnecessary when importing a database backup.
sudo -u postgres psql -c "CREATE EXTENSION hstore;"
sudo -u postgres createdb dcloud_$RAILS_ENVIRONMENT
sudo -u postgres createdb dcloud_analytics_$RAILS_ENVIRONMENT
sudo -u postgres createdb dcloud_crowd_$RAILS_ENVIRONMENT
cd /home/$USERNAME/documentcloud
sudo -u postgres psql -f db/development_structure.sql dcloud_$RAILS_ENVIRONMENT #2>&1|grep ERROR
sudo -u postgres psql -f db/analytics_structure.sql dcloud_analytics_$RAILS_ENVIRONMENT #2>&1|grep ERROR
sudo su - $USERNAME -c "cd /home/$USERNAME/documentcloud && rake db:migrate"
echo DATABASE SETUP COMPLETED SUCCESSFULLY
