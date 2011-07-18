namespace :db do

  desc "Back up the production database EBS as a snapshot on S3"
  task :backup, :needs => :environment do
    DC::Store::BackgroundJobs.backup_database
  end
  
  desc "VACUUM ANALYZE the Postgres DB"
  task :vacuum_analyze, :needs => :environment do
    DC::Store::BackgroundJobs.vacuum_analyze
  end
  
  desc "Optimize the Solr Index"
  task :optimize_solr, :needs => :environment do
    DC::Store::BackgroundJobs.optimize_solr
  end

  desc "Start Postgrest on Ubuntu"
  task :start do
    sh "sudo /etc/init.d/postgresql-8.4 start"
  end
  
  desc "Apply db tasks in custom databases, for example  rake db:alter[db:migrate,test-es] applies db:migrate on the database defined as test-es in databases.yml"
  task :alter, [:task,:database] => [:environment] do |t, args|
    require 'activerecord'
    puts "Applying #{args.task} on #{args.database}"
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[args.database])
    Rake::Task[args.task].invoke
  end

end