namespace :mail do
  
  task :csv, :needs => :environment do
    # Email on the 1st and 15th of each month
    if [1, 15].include? Date.today.day
      LifecycleMailer.deliver_document_csvs
      LifecycleMailer.deliver_account_csvs
    end
  end
end