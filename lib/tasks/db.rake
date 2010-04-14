namespace :db do

  desc "Back up the production database EBS as a snapshot on S3"
  task :backup, :needs => :environment do
    DC::Store::BackgroundJobs.backup_database
  end

end