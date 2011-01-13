namespace :mail do
  
  task :csv, :needs => :environment do
    # Email on the 1st and 15th of each month
    if [1, 13, 15].include? Date::today.mday
      LifecycleMailer.deliver_account_and_document_csvs
    end
  end
end