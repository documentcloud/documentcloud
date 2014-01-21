module DC
  module Store

    # Module for firing one-off background jobs via CloudCrowd.
    module BackgroundJobs

      def self.vacuum_analyze
        fire_job(:action => 'vacuum_analyze', :inputs => [true])
      end
      
      def self.optimize_solr
        fire_job(:action => 'optimize_solr', :inputs => [true])
      end

      def self.backup_database
        fire_job(:action => 'backup_database', :inputs => [true])
      end

      def self.reindex_everything( ids = Document.ids )
        fire_job(:action => 'reindex_everything', :inputs => ids)
      end

      private

      def self.fire_job(job)
        RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => job.to_json})
      end

    end

  end
end
