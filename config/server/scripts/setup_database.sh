#!/bin/bash

USERNAME=ubuntu
RAILS_ENVIRONMENT=production

echo "deb http://apt.postgresql.org/pub/repos/apt/ saucy-pgdg main" > /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

PACKAGES='
postgresql-9.3
postgresql-client-9.3
postgresql-contrib-9.3
'
echo $PACKAGES | xargs apt-get install -y

## setup dummy postgres environment so that you can verify rails is working
cp /etc/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.default.conf
cp config/server/files/postgres/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
cp /etc/postgresql/9.3/main/postgresql.conf /etc/postgresql/9.3/main/postgresql.default.conf
cp config/server/files/postgres/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
/etc/init.d/postgresql reload
sudo -u postgres createuser -s ubuntu
sudo -u postgres createuser -s documentcloud
sudo -u postgres psql -c "alter user documentcloud password 'YOUR_DB_PASSWORD_GOES_HERE' "
sudo -u postgres psql -c "CREATE EXTENSION hstore;"
sudo -u postgres createdb dcloud_$RAILS_ENVIRONMENT
sudo -u postgres createdb dcloud_analytics_$RAILS_ENVIRONMENT
sudo -u postgres createdb dcloud_crowd_$RAILS_ENVIRONMENT
cd /home/$USERNAME/documentcloud
sudo -u postgres psql -f db/development_structure.sql dcloud_$RAILS_ENVIRONMENT 2>&1|grep ERROR
sudo -u postgres psql -f db/analytics_structure.sql dcloud_analytics_$RAILS_ENVIRONMENT 2>&1|grep ERROR
rake $RAILS_ENVIRONMENT db:migrate
