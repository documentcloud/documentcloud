namespace :db do

  desc "Back up the production database EBS as a snapshot on S3"
  task :backup, :needs => :environment do
    DC::Store::BackgroundJobs.backup_database
  end

  desc "Update remote URLs from the Analytics DB"
  task :update_remote_urls, :needs => :environment do
    DC::Store::BackgroundJobs.update_remote_urls
  end

  desc "Start Postgrest on Ubuntu"
  task :start do
    sh "sudo /etc/init.d/postgresql-8.4 start"
  end

end