
namespace :aws do

  desc "Launch a new EC2 instance"
  task :new_instance, :instance_type, :needs => :environment do |t,args|

    require 'right_aws'
    ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])
    
    # 32bit custom AMI based on snap-05235d6c
    image_id = 'ami-f4db369d'
    # m1.small c1.medium m1.large , etc
    default_instance_type = 'm1.small' 
    
    instance_count = 1
    group = ['default']
    keypair = 'documentcloud'
    userdata = 'blank'
    addressing_type = 'public'
    instance_type = args.instance_type || default_instance_type
    zone = 'us-east-1c'
    
    ssh_config = {
      'CheckHostIP' => 'no', 
      'StrictHostKeyChecking' => 'no', 
      'UserKnownHostsFile' => '/dev/null', 
      'User' => 'ubuntu', 
      'IdentityFile' => Rails.root + "/config/server/keys/documentcloud.pem"
    }

    File.chmod(0600, ssh_config['IdentityFile'])

    new_instance = ec2.run_instances(image_id, instance_count, instance_count, group, keypair, userdata, addressing_type, instance_type, nil, nil, zone)[0]

    # wait until instance is running and get the public dns name
    while true do
      new_instance = ec2.describe_instances(new_instance[:aws_instance_id])[0]
      if new_instance[:aws_state] != 'pending'
        break
      end
      puts "waiting for instance #{new_instance[:aws_instance_id]} state to become 'running'"
      sleep 2
    end

    # wait until the instance is running sshd
    ssh_options = ssh_config.collect {|k,v| "-o #{k}=#{v}"}.join " "
    while true do
      if system "ssh -o ConnectTimeout=10 #{ssh_options} #{new_instance[:dns_name]} exit 0 2>/dev/null"
        break
      end
      puts "waiting for instance #{new_instance[:aws_instance_id]} / #{new_instance[:dns_name]} to start sshd "
      sleep 2
    end

    # run first_boot.sh script to configure new instance
    system "ssh #{ssh_options} #{new_instance[:dns_name]} sudo bash -x < #{Rails.root}/config/server/first_boot.sh"

    puts "ssh #{ssh_options} #{new_instance[:dns_name]}"
  end
end
