desc "Deploy via git to ec2 staging"
task :deploy do
  # First, the main server.
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'rake staging crowd:server:stop app:stop'
  todo << 'if [ -d public/assets ]; then rm -r public/assets; fi'
  todo << 'git pull'
  todo << 'rake staging db:migrate crowd:server:start app:start'
  system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@75.101.222.118 '#{todo.join(' && ')}'"

  # Then the CloudCrowd worker server.
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'sleep 2' # Wait for the CloudCrowd server to wake up.
  todo << 'rake staging crowd:node:stop'
  todo << 'git pull'
  todo << 'rake staging crowd:node:start'
  system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@174.129.169.143 '#{todo.join(' && ')}'"
end