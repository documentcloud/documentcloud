
namespace :aws do

  desc "Launch a new unconfigured EC2 instance and configure it for documentcloud"
  task :new_instance_from_scratch, :instance_type, :needs => :environment do |t,args|
    DC::AWS.new.boot_instance({
      :type     => args.instance_type,
      :scripts  => [DC::AWS::SCRIPTS[:scratch]]
    })
  end

  desc "Launch a new preconfigured EC2 instance"
  task :new_instance, :instance_type, :needs => :environment do |t,args|
    DC::AWS.new.boot_instance({
      :type     => args.instance_type,
      :scripts  => [DC::AWS::SCRIPTS[:update]]
    })
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

end
