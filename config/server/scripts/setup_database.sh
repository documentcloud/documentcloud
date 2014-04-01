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
echo $PACKAGES $TESSERACT_LANGUAGES $RUBY_DEPENDENCIES | xargs apt-get install -y

## setup dummy postgres environment so that you can verify rails is working
#cp config/server/postgres/pg_hba.conf  /etc/postgresql/9.0/main/pg_hba.conf
#/etc/init.d/postgresql reload
#sudo -u postgres createuser -s ubuntu
#sudo -u postgres createuser -s documentcloud
#sudo -u postgres psql -c "alter user documentcloud password 'YOUR_DB_PASSWORD_GOES_HERE' "
#sudo -u postgres createdb dcloud_$RAILS_ENVIRONMENT
#cd /home/$USERNAME/documentcloud
#sudo -u postgres psql -f db/development_structure.sql dcloud_$RAILS_ENVIRONMENT 2>&1|grep ERROR
## rake $RAILS_ENVIRONMENT db:migrate
