desc "Deploy via git to ec2 staging"
task :deploy do
  # First, the main server.
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'crowd -c config/cloud_crowd/staging server stop'
  todo << 'thin stop'
  todo << 'rm -r public/assets'
  todo << 'rm -r public/sprockets.js'
  todo << 'git pull'
  todo << 'crowd -c config/cloud_crowd/staging -d server start'
  todo << 'thin -e staging -p 80 -d start'
  system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@75.101.222.118 '#{todo.join(' && ')}'"
  
  # Then the CloudCrowd worker server.
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'crowd -c config/cloud_crowd/staging node stop'
  todo << 'git pull'
  todo << 'sleep 1'
  todo << 'crowd -c config/cloud_crowd/staging -d node start'
  system "ssh -t -i /Users/jashkenas/Desktop/id-documentcloud-staging root@174.129.169.143 '#{todo.join(' && ')}'"
end