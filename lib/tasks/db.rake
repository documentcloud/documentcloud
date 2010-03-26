namespace :db do

  desc "Back up the production database EBS as a snapshot on S3"
  task :backup, :needs => :environment do
    raise 'only the production database should be backed up' unless Rails.env.production?
    DC::AWS.new.create_snapshot(DC_CONFIG['db_volume_id'])
  end

end