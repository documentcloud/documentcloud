module CloudCrowd
  class NodeWrangler
    DEFAULT_WORKER_MATCHER=/^worker/

    attr_accessor :nodes, :threads

    def initialize(options = {})
      @user            = options[:user]     || "ubuntu"
      @key_path        = options[:key_path] || "secrets/keys/documentcloud.pem"
      @script_dir_path = options[:script_dir_path] || File.join(File.dirname(__FILE__), '..', '..', 'secrets', 'scripts', 'cloud_crowd')
      @scripts         = {}
      @threads         = []
    end

    # A wrangler will execute a shell script across a a list of hosts
    def execute_on_hosts(script, hosts)
      hosts.each do |host|
        @threads.push(Thread.new{
          puts "SSHing to #{host}:\n" + `ssh #{ssh_options} #{host} "bash -ls" <<SCRIPT\n#{script}\nSCRIPT`
        })
      end
      @threads.each{ |t| t.join }
      return hosts
    end

    # this method should be abstracted or generalized to take a block, or both.
    # For DocumentCloud's purposes, we're running on Amazon & name extra nodes "workers"
    # so we fetch the list of machines using a regexp.
    def get_hosts_named(pattern=DEFAULT_WORKER_MATCHER)
      ec2 = AWS::EC2.new
      puts "Fetching worker host names"
      instances = ec2.instances.select{ |i| i.status == :running && i.tags["Name"] =~ pattern }
      return instances.map{ |i| i.dns_name }
    end

    def run_on_workers(script, pattern=DEFAULT_WORKER_MATCHER)
      @nodes = get_hosts_named(pattern) if @nodes.nil? or @nodes.empty?
      execute_on_hosts(script, @nodes)
    end

    def start_nodes(pattern=DEFAULT_WORKER_MATCHER)
      run_on_workers(script_contents("startup"), pattern)
    end

    def kill_nodes(pattern=DEFAULT_WORKER_MATCHER)
      run_on_workers(script_contents("kill"), pattern)
    end

    # Start new ec2 instance(s) and provision them as worker nodes.
    # Options:
    #   :count - Number of nodes to start, defaults to 1
    #   :node_name - What to name the nodes once they're booted, defaults to "worker"
    def launch_nodes(options={})
      node_name = options.delete(:node_name) || "worker"
      options = {
        :count             => 1,
        :instance_type     => 'c3.large',
        :image_id          => DC::SECRETS['ami'],
        :security_groups   => DC::SECRETS['aws_security_group'],
        :key_name          => DC::SECRETS['aws_ssh_key_name'],
        :availability_zone => DC::CONFIG['aws_zone']
      }.merge(options)

      ec2 = AWS::EC2.new
      puts "Booting up #{options[:count]} new #{'node'.pluralize(options[:count].to_i)}"
      new_instances = ec2.instances.create( options )
      new_instances = [ new_instances ] unless new_instances.is_a?(Array) # launching a single
      # tag them all with Name=<node_name>
      new_instances.each{ |instance|  instance.tag('Name', value: node_name ) }
      # wait for Amazon to report them all non-pending
      sleep 1 while new_instances.any? {|i| :pending == i.status }
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
      host_names = new_instances.map(&:dns_name)
      execute_on_hosts(script_contents("startup"), host_names)
    end

    # To be implemented.
    # N.B. - needs to take into account "special" nodes like worker04
    def shutdown_nodes(pattern=DEFAULT_WORKER_MATCHER)
      # run_on_workers(script_contents("kill"), pattern)
    end

    def list_processes(pattern=DEFAULT_WORKER_MATCHER)
      run_on_workers(script_contents("list_processes"), pattern)
    end

    private
    def ssh_options
      "-o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -l '#{@user}' -i '#{@key_path}'"
    end

    def script_contents(name)
      unless @scripts[name]
        script_path = File.join(@script_dir_path, "#{name}.sh")
        raise ArgumentError, "Couldn't find a script for '#{name}' in #{@script_dir_path}" unless File.exists? script_path
        @scripts[name] = File.open(script_path).read
      end
      @scripts[name]
    end
  end
end
