# A ProcessingJob is the record of an active job on CloudCrowd.
class ProcessingJob < ActiveRecord::Base
  
  belongs_to :account
  
  validates_presence_of :account_id, :cloud_crowd_id
  
  attr_accessor :remote_job
  
  # Return the JSON-ready Job status.
  def status
    (@remote_job || fetch_job).merge({'id' => self.id})
  end
  
  # Fetch the current status of the job from CloudCrowd.
  def fetch_job
    JSON.parse(RestClient.get(url))
  end
  
  # The URL of the Job on CloudCrowd.
  def url
    "#{DC_CONFIG['cloud_crowd_server']}/jobs/#{cloud_crowd_id}"
  end
  
end