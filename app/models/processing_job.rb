# A ProcessingJob is the record of an active job on CloudCrowd.
class ProcessingJob < ActiveRecord::Base

  belongs_to :account
  belongs_to :document

  validates :cloud_crowd_id, :presence=>true

  attr_accessor :remote_job

  # Return the JSON-ready Job status.
  def status
    (@remote_job || fetch_job).merge(attributes)
  end

  # Fetch the current status of the job from CloudCrowd.
  def fetch_job
    JSON.parse(RestClient.get(url).body)
  end

  # The URL of the Job on CloudCrowd.
  def url
    "#{DC::CONFIG['cloud_crowd_server']}/jobs/#{cloud_crowd_id}"
  end

  # The default JSON of a processing job is just enough to get it polling for
  # updates again.
  def as_json(opts={})
    { 'id'      => id,
      'title'   => title,
      'status'  => 'loading'
    }
  end

end
