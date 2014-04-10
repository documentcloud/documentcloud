
namespace :aws do

  desc "Launch a new unconfigured EC2 instance and configure it for documentcloud"
  task :new_instance_from_scratch, [:instance_type] => :environment do |t,args|
    DC::AWS.new.boot_instance({
      :type     => args.instance_type,
      :scripts  => [DC::AWS::SCRIPTS[:scratch]]
    })
  end

  desc "Launch a new preconfigured EC2 instance"
  task :new_instance, [:instance_type] => :environment do |t,args|
    DC::AWS.new.boot_instance({
      :type     => args.instance_type,
      :scripts  => [DC::AWS::SCRIPTS[:update]]
    })
  end

  desc "Snapshot EBS root and register it as a new AMI"
  task :register_ami, [:instance_id] => [:environment] do |t,args|
    require 'right_aws'
    aws = DC::AWS.new

    instance = aws.ec2.instances[ args.instance_id ]
    if :running == instance.status
      puts "It is recommended to halt the instance before snapshotting. You have 5 seconds to ctrl-c interrupt."
      sleep 5
    end

    image = aws.ec2.images[ :aws_image_id]
    volume = aws.ec2.volumes.detect{ |vol| vol.attachments.include?( args.instance_id ) }

    new_snapshot = volume.create_snapshot
    while :pending == new_snapshot.status do
      puts "#{new_snapshot.volume_id} status: #{new_snapshot.status} progress: #{new_snapshot.progress}"
      sleep 2
    end

    puts "ec2-register --snapshot #{new_snapshot.id} --kernel #{instance.kernel_id} --ramdisk #{instance.ramdisk_id} --description='dcloud revision of #{instance.image_id}' --name='#{instance.image_id}/#{new_snapshot.id}.manifest.xml' --architecture #{image.architecture} --root-device-name /dev/sda1"
  end

end
