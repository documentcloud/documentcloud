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
          puts "SSHing to #{host}:\n" + `ssh -o "StrictHostKeyChecking no" -i #{@key_path} #{@user}@#{host} "bash -ls" <<SCRIPT\n#{script}\nSCRIPT`
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
      return instances.map{ |i| i.public_dns_name }
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
    
    def list_processes(pattern=DEFAULT_WORKER_MATCHER)
      run_on_workers(script_contents("list_processes"), pattern)
    end
    
    private
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
