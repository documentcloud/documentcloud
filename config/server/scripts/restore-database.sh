######################################################################
## This is a collection of commands to setup a                      ##
## new Postgresql server and restore a database backup onto it.     ##
##                                                                  ##
## It's not intended as a script, but instead for each to be ran    ##
## individually, so the output can be monitored                     ##
######################################################################

# Find ebs volume.  It'll be recongnizable by the size, (most likely xvdd)
sudo lsblk

# Create a ext4 filesystem with 0 reserved blocks
sudo mkfs.ext4 -m 0 /dev/xvdd

# make mount point directory and add it to fstab
# The fstab entry specifies "noatime" for a little more performance
sudo mkdir /srv/pg
sudo chmod 777 /srv/pg
echo "/dev/xvdd    /srv/pg    ext4    noatime    0    0" | sudo tee -a /etc/fstab
sudo mount /srv/pg

# Checkout source
sudo apt-get install git
git clone https://github.com/documentcloud/documentcloud.git
cd ~/documentcloud

# Run configuration scripts
sudo sh ./config/server/scripts/setup_common_dependencies.sh
# initialize chruby
. /etc/profile.d/chruby.sh
# setup the db
sudo sh ./config/server/scripts/setup_database.sh

# Move and soft link DB install onto new mount point
sudo service postgresql stop
sudo mv /var/lib/postgresql/* /srv/pg/
sudo rmdir /var/lib/postgresql
sudo ln -s /srv/pg /var/lib/postgresql
sudo service postgresql start

# configure AWS CLI
sudo apt-get install awscli
export AWS_ACCESS_KEY_ID=`grep aws_access_key secrets/secrets.yml |awk '{print $2}'`
export AWS_SECRET_ACCESS_KEY=`grep aws_secret_key secrets/secrets.yml |awk '{print $2}'`
export AWS_DEFAULT_REGION=us-east-1

# The DB backup to restore from
export DATE=2014-12-28

# Download the backups, takes around 10 minutes
aws s3 cp s3://s3.documentcloud.org/backups/dcloud_production/$DATE.dump /srv/pg/$DATE-production.dump
aws s3 cp s3://s3.documentcloud.org/backups/dcloud_analytics_production/$DATE.dump /srv/pg/$DATE-analytics.dump

# restoring takes considerably longer.
# As of Jan 3rd, 2015 - 92 mins for production, 28 for analytics
pg_restore -Udocumentcloud -d dcloud_production /srv/pg/$DATE-production.dump
pg_restore -Udocumentcloud -d dcloud_analytics_production /srv/pg/$DATE-production.dump

# cleanup the backup dumps
rm /srv/pg/*dump
