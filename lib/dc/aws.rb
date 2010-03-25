module DC

  # Utility AWS class for some simple Amazon management.
  class AWS

    def initialize
      @ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])
    end

    def describe_instances
      @ec2.describe_instances
    end

    def boot_instance(image_id=nil, instance_type=nil, config_script=nil)
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

      File.chmod(0600, ssh_config['IdentityFile'])

      new_instance = @ec2.run_instances(image_id, instance_count, instance_count, group, keypair, userdata, addressing_type, instance_type, nil, nil, zone)[0]

      # wait until instance is running and get the public dns name
      while true do
        sleep 2
        new_instance = @ec2.describe_instances(new_instance[:aws_instance_id])[0]
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

end