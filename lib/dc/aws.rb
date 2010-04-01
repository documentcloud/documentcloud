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
      :ami      => DC_CONFIG['preconfigured_ami_id'],
      :type     => 'm1.small',
      :scripts  => [SCRIPTS[:update]]
    }

    # Create our EC2 connection upon initialization.
    def initialize
      @ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])
    end

    # Describe the running instances.
    def describe_instances
      begin
        @ec2.describe_instances
      rescue RightAws::AwsError => e
        Rails.logger.error e.message
        []
      end
    end

    # Describe our current snapshots.
    def describe_snapshots
      @ec2.describe_snapshots
    end

    def create_snapshot(volume_id)
      @ec2.create_snapshot(volume_id)
    end

    # Boot a new instance, given `ami`, `type`, and `scripts` options.
    def boot_instance(options)
      options = DEFAULT_BOOT_OPTIONS.merge(options)
      instance_count = 1
      group = ['default']
      keypair = 'documentcloud'
      userdata = 'blank'
      addressing_type = 'public'
      zone = DC_CONFIG['aws_zone']

      ssh_config = {
        'CheckHostIP' => 'no',
        'StrictHostKeyChecking' => 'no',
        'UserKnownHostsFile' => '/dev/null',
        'User' => 'ubuntu',
        'IdentityFile' => "#{Rails.root}/config/server/keys/documentcloud.pem"
      }

      File.chmod(0600, ssh_config['IdentityFile'])

      new_instance = @ec2.run_instances(options[:ami], instance_count, instance_count, group, keypair, userdata, addressing_type, options[:type], nil, nil, zone)[0]

      # wait until instance is running and get the public dns name
      while true do
        sleep 2
        new_instance = @ec2.describe_instances(new_instance[:aws_instance_id])[0]
        break if new_instance[:aws_state] != 'pending'
        Rails.logger.info "waiting for instance #{new_instance[:aws_instance_id]} state to become 'running'"
      end

      # wait until the instance is running sshd
      ssh_options = ssh_config.collect {|k,v| "-o #{k}=#{v}"}.join " "
      while true do
        sleep 2
        break if system "ssh -o ConnectTimeout=20 #{ssh_options} #{new_instance[:dns_name]} exit 0 2>/dev/null"
        Rails.logger.info "waiting for instance #{new_instance[:aws_instance_id]} / #{new_instance[:dns_name]} to start sshd "
      end

      # configure new instance with ssh key to access github
      system "ssh #{ssh_options} #{new_instance[:dns_name]} 'test -e .ssh/id_dsa && exit 0; mkdir -p .ssh; while read line; do echo $line; done > .ssh/id_dsa; chmod 0600 .ssh/id_dsa' < #{Rails.root}/config/server/keys/github.pem"

      # configure new instance
      unless options[:scripts].empty?
        options[:scripts].each do |script|
          system "ssh #{ssh_options} #{new_instance[:dns_name]} sudo bash -x < #{script}"
        end
      end

      Rails.logger.info "ssh #{ssh_options} #{new_instance[:dns_name]}"
    end

    # Terminate an instance on EC2
    def terminate_instance(instance_id)
      @ec2.terminate_instances([instance_id])
    end

  end

end