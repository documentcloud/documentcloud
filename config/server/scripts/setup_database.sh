#!/bin/bash

# exit the script if any of the commands fail.
# further discussion: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
echo BEGINNING SETUP DATABASE

set -e

# Setting up database requires knowing 2 pieces of information (and 1 optional piece of info)
# which must be passed in to the script in this order:
#  1) the rails environment
#  2) the database password
#  3) the setup user (which will be inferred from the login user)

RAILS_ENVIRONMENT=${1:-"$RAILS_ENV"} 
# If environment is not set exit script.  Make Command line priority.
if [ ! -n "$RAILS_ENVIRONMENT" ]; then 
  echo "environment must be set in RAILS_ENV or passed as first argument. CLI will be priority" >&2; exit 1;
fi

PASSWORD_ARG=$2
if [ ! -n "$PASSWORD_ARG" ]; then 
  echo "database password must passed as second argument." >&2; exit 1;
fi

# This script needs to be run as root for permission purposes
test $USER = 'root' || { echo run this as root >&2; exit 1; }
# but the user we actually care about is the login user.
LOGINUSER=$(logname)      # login user is ubuntu for a vanilla ubuntu installation.
USERNAME=${3:-$LOGINUSER} # but this can be overridden by passing a username as the third argument.

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
sudo -u postgres createuser -s documentcloud
sudo -u postgres psql -c "alter user documentcloud password '$PASSWORD_ARG' "
sudo -u postgres createdb -O documentcloud dcloud_$RAILS_ENVIRONMENT
sudo -u postgres createdb -O documentcloud dcloud_analytics_$RAILS_ENVIRONMENT
sudo -u postgres createdb -O documentcloud dcloud_crowd_$RAILS_ENVIRONMENT

sudo -u postgres psql -f /home/$USERNAME/documentcloud/db/analytics_structure.sql dcloud_analytics_$RAILS_ENVIRONMENT #2>&1|grep ERROR
sudo su -l $USERNAME <<RAILS
cd /home/$USERNAME/documentcloud
RAILS_ENV=$RAILS_ENVIRONMENT rake db:structure:load
RAILS_ENV=$RAILS_ENVIRONMENT rake db:migrate
RAILS
echo DATABASE SETUP COMPLETED SUCCESSFULLY
