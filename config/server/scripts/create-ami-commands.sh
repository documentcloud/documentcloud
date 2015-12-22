# STEPS

# 1) get AMI from https://cloud.ubuntu.com/ami and follow the link.
#    as of right now (2015-10-26) the link is here: https://console.aws.amazon.com/ec2/home?region=us-east-1#launchAmi=ami-11f9aa74
#    we're using us-east-1 instance-store amd64 instances
#    Launch the instance as desired.

# 2) Attach a 30gb EBS drive to the newly launched instance, as xvdf or whatever you want it to be called.
#    and note it directly below.
DEVICE=/dev/xvdf

# Format the drive if necessary with the following command
#sudo mkfs -t ext4 $DEVICE

#    Then create a mount point for the EBS drive
#    and mount the drive
sudo mkdir /mnt/ami
sudo mount $DEVICE /mnt/ami/

# 3) Set up the application.
#    For DocumentCloud the process goes like this (after you've scp'd up the scripts dir & github key)
sudo ./scripts/setup_common_dependencies.sh
source /etc/profile.d/chruby.sh
gem install bundler
./scripts/setup_app.sh

pushd documentcloud
git clone git@github.com:documentcloud/documentcloud-secrets secrets
bundle install
rails runner -e production "puts Organization.count" # check for human eyeballs
sudo mkdir /mnt/cloud_crowd
sudo chown ubuntu:ubuntu /mnt/cloud_crowd

# 4) Install the AWS command line tools:

# Install the AMI and API tools
sudo apt-get install ec2-ami-tools ec2-api-tools -y

ACCESS_KEY=$(egrep "aws_access_key"  ~/documentcloud/secrets/secrets.yml | awk '{print $NF}')
SECRET_KEY=$(egrep "aws_secret_key"  ~/documentcloud/secrets/secrets.yml | awk '{print $NF}')

# check for human eyeballs
ec2-describe-regions --aws-access-key $ACCESS_KEY --aws-secret-key $SECRET_KEY

# use the --no-filter flag so that /etc/ssl/certs/*.pem don't get deleted.
sudo -E su
ec2-bundle-vol \
  --privatekey /home/ubuntu/documentcloud/secrets/keys/ami_signing.key                                  \
  --cert /home/ubuntu/documentcloud/secrets/keys/ami_signing.pem                                        \
  --user $(egrep "aws_account_id"  /home/ubuntu/documentcloud/secrets/secrets.yml | awk '{print $NF}')  \
  --arch x86_64 --destination /mnt/ami                                                                  \
  --include /mnt/cloud_crowd --no-filter
exit

AMI_NAME=dc-worker-ephemeral-$(date +'%Y-%m-%d')
ec2-upload-bundle -b dcloud-ami/$AMI_NAME -m /mnt/ami/image.manifest.xml -a $ACCESS_KEY -s $SECRET_KEY --location US

ec2-register dcloud-ami/$AMI_NAME/image.manifest.xml -n $AMI_NAME -O $ACCESS_KEY -W $SECRET_KEY --region us-east-1

# echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts

# Biblography
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.html#bundle-ami-prerequisites
#  Note that the above link is out of date.  Grub does not need to be updated (for one)
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
# http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html
# http://alestic.com/2012/05/aws-command-line-packages
# http://stackoverflow.com/questions/16480846/x-509-private-public-key

# Additional Reading
# http://sorcery.smugmug.com/2014/01/29/instance-store-hvm-amis-for-amazon-ec2/
# https://launchpad.net/~awstools-dev/+archive/ubuntu/awstools

# Reading about IOPS
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-workload-demand.html
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-volume-status.html
# https://www.datadoghq.com/2013/08/aws-ebs-latency-and-iops-the-surprising-truth/
# https://www.datadoghq.com/2013/07/detecting-aws-ebs-performance-issues-with-datadog/
# http://www.datadoghq.com/wp-content/uploads/2013/07/top_5_aws_ec2_performance_problems_ebook.pdf
# http://www.slideshare.net/AmazonWebServices/ebs-webinarfinal