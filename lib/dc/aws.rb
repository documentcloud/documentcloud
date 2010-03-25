module DC

  # Utility AWS class for some simple Amazon management.
  class AWS

    def initialize
      @ec2 = RightAws::Ec2.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'])
    end

    def instances
      @ec2.describe_instances
    end

  end

end