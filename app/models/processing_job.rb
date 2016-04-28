# A ProcessingJob is the point of control for 
# initiating and checking on CloudCrowd::Jobs.
class ProcessingJob < ActiveRecord::Base
  #include DC::Status

  belongs_to :account
  belongs_to :document

  validates :cloud_crowd_id, :presence=>true
  #validates :action, :presence => true

  attr_accessor :remote_job
  
  scope :incomplete, ->{ where :complete => false }
  
  # Quick lookup to find a ProcessingJob from JSON of a CloudCrowd::Job
  def self.lookup_by_remote(attrs)
    self.find_by_cloud_crowd_id attrs.fetch('id')
  end
  
  # CloudCrowd endpoint to POST work to.
  def self.endpoint
    "#{DC::CONFIG['cloud_crowd_server']}/jobs"
  end
  
  # A serializer which outputs the attributes needed
  # to post to CloudCrowd.
  class CloudCrowdSerializer < ActiveModel::Serializer
    attributes :action, :inputs, :options, :callback_url
    
    def options; object.options; end
    
    # inputs should always be an array of documents.
    def inputs; [object.document_id]; end
    
    def callback_url
      case object.action
      when "update_access"
        "#{DC.server_root(:ssl => false)}/import/update_access"
      else
        "#{DC.server_root(:ssl => false)}/import/cloud_crowd"
      end
    end
  end
  
  # Validate and initiate this job with CloudCrowd.
  def queue
    # If a Document is associated with this ProcessingJob, determine
    # whether the Document is available to be worked on, and if it's not
    # use ActiveRecord's error system to indicate it's unavailability.
    #if document and document.has_running_jobs?
    #  errors.add(:document, "This document is already being processed") and (return false)
    #
    #  # in future we'll actually lock the document
    #  # Lock the document & contact CloudCrowd to start the job
    #  #document.update :status => UNAVAILABLE
    #end
    
    begin
      # Note the job id once CloudCrowd has recorded the job.
      @response = RestClient.post(ProcessingJob.endpoint, {:job => CloudCrowdSerializer.new(self).to_json})
      @remote_job = JSON.parse @response.body
      self.cloud_crowd_id = @remote_job['id']

      # We've collected all the info we need, so
      save # it and retain the lock on the document.
    rescue Errno::ECONNREFUSED, RestClient::Exception => error
      LifecycleMailer.exception_notification(error).deliver_now
      # In the event of an error while communicating with CloudCrowd, unlock the document.
      self.update_attributes :complete => true
      #document.update :status => AVAILABLE
      raise error
    end
  end
  
  def resolve(cloud_crowd_job, &blk)
    @remote_job = cloud_crowd_job
    begin
      # Handle Document Jobs
      if self.document
        unless @remote_job['status'] == "succeeded"
          logger.error("Document import failed: " + @remote_job.inspect)
          document.update_attributes(:access => DC::Access::ERROR)
        end
      end
      blk.call(self) if blk
    ensure
      self.update_attributes :complete => true
    end
  end
  
  # We'll store options as a JSON string, so we need to 
  # cast it into a string when options are assigned.
  #
  # WARNING: if you monkey around with the contents of options
  # after it's assigned changes to the options won't be saved.
  def options=(opts)
    @parsed_options = opts
    write_attribute :options, @parsed_options.to_json
  end
  
  def options
    @parsed_options ||= JSON.parse(read_attribute :options)
  end

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
    "#{ProcessingJob.endpoint}/#{cloud_crowd_id}"
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