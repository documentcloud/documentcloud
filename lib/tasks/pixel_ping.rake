namespace :ping do

  command = "node ../pixel-ping/pixel-ping.js config/pixel_ping/#{RAILS_ENV}.json"

  task :stop do
    sh "kill `cat log/pixel_ping.pid`; rm log/pixel_ping.pid"
  end

  task :run do
    sh command
  end

  task :start do
    sh "nohup #{command} > log/pixel_ping.log 2>&1 & echo $! > log/pixel_ping.pid"
  end

  task :restart => [:stop, :start]

end


