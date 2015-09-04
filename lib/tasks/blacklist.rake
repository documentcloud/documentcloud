
namespace :blacklist do

  desc "Remove blacklist on Open Calais for daily limit reset"
  task :free_calais => :environment do
    RestClient.delete DC::CONFIG['cloud_crowd_server'] + File.join("/","blacklist","reprocess_entities")
  end

end
