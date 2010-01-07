desc "Deploy via git to ec2 staging"
task :deploy do
  # First, the main server.
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'git pull'
  todo << 'su www-data -c "jammit -u http://staging.dcloud.org"'
  todo << 'rake staging crowd:server:restart crowd:node:restart db:migrate app:restart app:warm'
  system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@75.101.222.118 '#{todo.join(' && ')}'"

  # Then the CloudCrowd worker server.
  # todo = []
  #   todo << 'cd /web/document-cloud'
  #   todo << 'sleep 2' # Wait for the CloudCrowd server to wake up.
  #   todo << 'rake staging crowd:node:stop'
  #   todo << 'git pull'
  #   todo << 'rake staging crowd:node:start'
  #   system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@174.129.169.143 '#{todo.join(' && ')}'"
end