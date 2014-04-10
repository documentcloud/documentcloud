require 'aws/ec2'

module DC

  # Utility AWS class for some simple Amazon management.
  class AWS

    # The launch scripts.
    SCRIPTS = {
      :scratch  => "#{Rails.root}/config/server/scripts/config_from_scratch.sh",
      :update   => "#{Rails.root}/config/server/scripts/update_preconfigured_instance.sh",
      :node     => "#{Rails.root}/config/server/scripts/launch_cloud_crowd_node.sh"
    }

    # Default AMI, instance type, and launch script to start a new instance.
    DEFAULT_BOOT_OPTIONS = {
      :ami      => DC::CONFIG['preconfigured_ami_id'],
      :type     => 'm1.small',
      :scripts  => [SCRIPTS[:update]]
    }

    def ec2
      @ec2 ||= ::AWS::EC2.new
    end

    # Describe the running instances.
    def describe_instances
      begin
        ec2.instances.map do | instance |
          {
            :aws_instance_id   => instance.id,
            :aws_instance_type => instance.instance_type,
            :aws_state         => instance.status,
            :dns_name          => instance.dns_name,
            :private_dns_name  => instance.private_dns_name
          }
        end
      rescue ::AWS::Errors::Base => e
        Rails.logger.error e.message
        []
      end
    end

    # Describe our current snapshots.
    def describe_snapshots
      ec2.snapshots.map do | snapshot |
        {
          :aws_id          => snapshot.id,
          :aws_volume_size => snapshot.volume_size,
          :aws_progress    => snapshot.progress,
          :aws_status      => snapshot.status,
          :aws_volume_id   => snapshot.volume_id,
          :aws_started_at  => snapshot.start_time
        }
      end
    end

    def create_snapshot(volume_id)
      ec2.volumes[ volume_id ].create_snapshot
    end

    # Boot a new instance, given `ami`, `type`, and `scripts` options.
    def boot_instance(options)
      options = DEFAULT_BOOT_OPTIONS.merge(options)

      ssh_config = {
        'CheckHostIP' => 'no',
        'StrictHostKeyChecking' => 'no',
        'UserKnownHostsFile' => '/dev/null',
        'User' => 'ubuntu',
        'IdentityFile' => "#{Rails.root}/secrets/keys/documentcloud.pem"
      }

      File.chmod(0600, ssh_config['IdentityFile'])

      new_instance = ec2.instances.create({
                                            :image_id          => options[:ami],
                                            :count             => 1,
                                            :security_groups   => ['default'],
                                            :key_name          => 'documentcloud',
                                            :instance_type     => options[:type],
                                            :availability_zone => DC::CONFIG['aws_zone']
                                          })
      if ( name = options[:name] )
        instance.tag('Name', value: name )
      end
      
      # wait until instance is running and get the public dns name
      while :pending == new_instance.status
        sleep 2
        Rails.logger.info "waiting for instance #{new_instance[:aws_instance_id]} state to become 'running'"
      end

      # wait until the instance is running sshd
      ssh_options = ssh_config.collect {|k,v| "-o #{k}=#{v}"}.join " "
      while true do
        sleep 2
        break if system "ssh -o ConnectTimeout=10 #{ssh_options} #{new_instance[:dns_name]} exit 0 2>/dev/null"
        Rails.logger.info "waiting for instance #{new_instance.instance_id} / #{new_instance.dns_name} to start sshd "
      end

      # configure new instance with ssh key to access github
      system "ssh #{ssh_options} #{new_instance[:dns_name]} 'test -e .ssh/id_dsa && exit 0; mkdir -p .ssh; while read line; do echo $line; done > .ssh/id_dsa; chmod 0600 .ssh/id_dsa' < #{Rails.root}/secrets/keys/github.pem"

      # configure new instance
      unless options[:scripts].empty?
        options[:scripts].each do |script|
          system "ssh #{ssh_options} #{new_instance[:dns_name]} sudo bash -x < #{script}"
        end
      end

      Rails.logger.info "ssh #{ssh_options} #{new_instance.dns_name}"
    end

    # Terminate an instance on EC2
    def terminate_instance(instance_id)
      ec2.instances[ instance_id ].terminate
    end

  end

end
