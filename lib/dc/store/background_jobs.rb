module DC
  module Store

    # Module for firing one-off background jobs via CloudCrowd.
    module BackgroundJobs

      def self.vacuum_analyze
        fire_job(:action => 'vacuum_analyze', :inputs => [true])
      end

      def self.backup_database
        fire_job(:action => 'backup_database', :inputs => [true])
      end

      def self.update_remote_urls
        fire_job(:action => 'update_remote_urls', :inputs => [true])
      end


      private

      def self.fire_job(job)
        RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => job.to_json})
      end

    end

  end
end