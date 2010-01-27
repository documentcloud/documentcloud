
namespace :aws do

  desc "Launch a new unconfigured EC2 instance and configure it for document-cloud"
  task :new_instance_from_scratch, :instance_type, :needs => :environment do |t,args|
    boot_and_configure_new_instance(nil, args.instance_type, "#{Rails.root}/config/server/config_from_scratch.sh")
  end

  desc "Launch a new preconfigured EC2 instance"
  task :new_instance, :instance_type, :needs => :environment do |t,args|
    boot_and_configure_new_instance(DC_CONFIG['preconfigured_ami_id'], args.instance_type, "#{Rails.root}/config/server/update_preconfigured_instance.sh")
  end

  desc "Snapshot EBS root and register it as a new AMI"
  task :register_ami, :instance_id, :needs => :environment do |t,args|
    require 'right_aws'
    ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])

    instance = ec2.describe_instances(args.instance_id)[0]
    if instance[:aws_state] == 'running'
      puts "It is recommended to halt the instance before snapshotting. You have 5 seconds to ctrl-c interrupt."
      sleep 5
    end

    image = ec2.describe_images(instance[:aws_image_id])[0]
    volume = ec2.describe_volumes.select {|vol| vol[:aws_instance_id] == args.instance_id}.first

    new_snapshot = ec2.create_snapshot volume[:aws_id]
    while true do
      sleep 2
      new_snapshot = ec2.describe_snapshots(new_snapshot[:aws_id])[0]
      puts "#{new_snapshot[:aws_id]} status: #{new_snapshot[:aws_status]} progress: #{new_snapshot[:aws_progress]}"
      break if new_snapshot[:aws_status] == 'completed'
    end

    puts "ec2-register --snapshot #{new_snapshot[:aws_id]} --kernel #{instance[:aws_kernel_id]} --ramdisk #{instance[:aws_ramdisk_id]} --description='dcloud revision of #{instance[:aws_image_id]}' --name='#{instance[:aws_image_id]}/#{new_snapshot[:aws_id]}.manifest.xml' --architecture #{image[:aws_architecture]} --root-device-name /dev/sda1"
  end    

  private

  def boot_and_configure_new_instance(image_id=nil, instance_type=nil, config_script=nil)
    require 'right_aws'
    ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])
    
    instance_count = 1
    group = ['default']
    keypair = 'documentcloud'
    userdata = 'blank'
    addressing_type = 'public'
    instance_type ||= 'm1.small'
    zone = DC_CONFIG['aws_zone']

    if image_id.nil?
      # by default use Karmic EBS root from Alestic 
      image_id = instance_type == 'm1.small' || instance_type == 'c1.medium' ? 'ami-6743ae0e' : 'ami-7d43ae14'
    end

    ssh_config = {
      'CheckHostIP' => 'no', 
      'StrictHostKeyChecking' => 'no', 
      'UserKnownHostsFile' => '/dev/null', 
      'User' => 'ubuntu', 
      'IdentityFile' => "#{Rails.root}/config/server/keys/documentcloud.pem"
    }

    if RAILS_ENV == 'development'
      ssh_config['IdentityFile'] = "/home/adler/.ec2/jerseyslicecom.pem"
      keypair = 'jerseyslice.com'
    end

    File.chmod(0600, ssh_config['IdentityFile'])

    new_instance = ec2.run_instances(image_id, instance_count, instance_count, group, keypair, userdata, addressing_type, instance_type, nil, nil, zone)[0]
    
    # wait until instance is running and get the public dns name
    while true do
      sleep 2
      new_instance = ec2.describe_instances(new_instance[:aws_instance_id])[0]
      break if new_instance[:aws_state] != 'pending'
      puts "waiting for instance #{new_instance[:aws_instance_id]} state to become 'running'"
    end

    # wait until the instance is running sshd
    ssh_options = ssh_config.collect {|k,v| "-o #{k}=#{v}"}.join " "
    while true do
      sleep 2
      break if system "ssh -o ConnectTimeout=20 #{ssh_options} #{new_instance[:dns_name]} exit 0 2>/dev/null"
      puts "waiting for instance #{new_instance[:aws_instance_id]} / #{new_instance[:dns_name]} to start sshd "
    end

    # configure new instance with ssh key to access github
    system "ssh #{ssh_options} #{new_instance[:dns_name]} 'test -e .ssh/id_dsa && exit 0; mkdir -p .ssh; while read line; do echo $line; done > .ssh/id_dsa; chmod 0600 .ssh/id_dsa' < #{Rails.root}/config/server/keys/github.pem"

    # configure new instance
    if ! config_script.nil? 
      system "ssh #{ssh_options} #{new_instance[:dns_name]} sudo bash -x < #{config_script}"
    end

    puts "ssh #{ssh_options} #{new_instance[:dns_name]}"
  end

end
