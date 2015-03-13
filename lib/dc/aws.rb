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
      :type     => 't2.micro',
      :scripts  => [SCRIPTS[:update]]
    }

    def initialize(options = {})
      @user     = options[:user]     || "ubuntu"
      @key_path = options[:key_path] || "secrets/keys/documentcloud.pem"
    end

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

    def launch_instances(options={}, &post_launch)
      node_name = options.delete(:node_name) || "workers"
      options = {
        :instance_type     => 'c3.large',
        :image_id          => DC::SECRETS['ami'],
        :security_groups   => DC::SECRETS['aws_security_group'],
        :key_name          => DC::SECRETS['aws_ssh_key_name'],
        :availability_zone => DC::CONFIG['aws_zone']
      }.merge(options)
      
      options[:count] = (options[:count] || 1).to_i unless options[:count].kind_of? Integer
      raise ArgumentError, "Count must be an integer > 0" unless options[:count] > 0
      
      puts "Booting up #{options[:count]} new #{'node'.pluralize(options[:count])}"
      new_instances = [ec2.instances.create( options )].flatten
      # tag them all with Name=<node_name>
      new_instances.each{ |instance|  instance.tag('Name', value: node_name ) }
      # wait for Amazon to report them all non-pending
      sleep 3 while new_instances.any? {|i| :pending == i.status }
      # Some may have failed, if so report on them and remove from list
      failed_instances = new_instances.find_all{|i| :running != i.status }
      if failed_instances.any?
        puts "#{failed_instances.map(&:dns_name)} failed to boot"
        new_instances -= failed_instances
      end
      if new_instances.none?
        puts "No instances launched successfully" and return false
      end
      booting_instances = new_instances.dup
      while booting_instances.any? do
        # an instance is fully booted if we can establish an ssh connection to it
        puts "Waiting for #{booting_instances.map(&:dns_name).join(", ")} to boot"
        booting_instances.delete_if do | instance |
           system "ssh -o ConnectTimeout=10 #{ssh_options} #{instance.dns_name} exit 0 2>/dev/null"
        end
        sleep 5
      end
      
      post_launch ? post_launch.yield(new_instances) : new_instances
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
                                            :key_name          => 'DocumentCloud 2014-04-12',
                                            :instance_type     => options[:type],
                                            :availability_zone => DC::CONFIG['aws_zone']
                                          })
      if ( name = options[:name] )
        new_instance.tag('Name', value: name )
      end
      
      # wait until instance is running and get the public dns name
      while :pending == new_instance.status
        sleep 2
        Rails.logger.info "waiting for instance #{new_instance.instance_id} state to become 'running'"
      end

      # wait until the instance is running sshd
      ssh_options = ssh_config.collect {|k,v| "-o #{k}=#{v}"}.join " "
      while true do
        sleep 2
        break if system "ssh -o ConnectTimeout=10 #{ssh_options} #{new_instance.dns_name} exit 0 2>/dev/null"
        Rails.logger.info "waiting for instance #{new_instance.instance_id} / #{new_instance.dns_name} to start sshd "
      end

      # configure new instance with ssh key to access github
      system "ssh #{ssh_options} #{new_instance.dns_name} 'test -e .ssh/id_dsa && exit 0; mkdir -p .ssh; while read line; do echo $line; done > .ssh/id_dsa; chmod 0600 .ssh/id_dsa' < #{Rails.root}/secrets/keys/github.pem"

      # configure new instance
      unless options[:scripts].empty?
        options[:scripts].each do |script|
          system "ssh #{ssh_options} #{new_instance.dns_name} sudo bash -x < #{script}"
        end
      end

      Rails.logger.info "ssh #{ssh_options} #{new_instance.dns_name}"
      return new_instance
    end

    # Terminate an instance on EC2
    def terminate_instance(instance_id)
      ec2.instances[ instance_id ].terminate
    end

    private
    def ssh_options
      "-q -o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -l '#{@user}' -i '#{@key_path}'"
    end

  end

end
