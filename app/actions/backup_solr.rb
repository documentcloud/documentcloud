require File.dirname(__FILE__) + '/support/setup'

# This action will take a snapshot of the Solr search index, Tar & Gzip it and store it on S3.

class BackupSolr < CloudCrowd::Action

  def process
    begin
      
      status = perform_solr_request('backup')
      unless REXML::XPath.first( status, '//str[@name="status" and text()="OK"]' ).text
        raise "Backup failed. xml:\n#{ status.to_s}"
      end

      status = perform_solr_request('details')
      unless REXML::XPath.first( status, '//lst[@name="backup"]/str[@name="status" and text()="success"]' ).text
        # Not 100% sure of what to do here.  My system always returns success but perhaps sometimes it returns pending
        # or some such.  Need to test with a large corpus and see if the backup command returns immediatly or waits for completion
        # For now: just raise an exception - We can examine the XML and adjust accordingly
        raise "Backup (maybe?) failed - xml is:\n#{status.to_s}"
      end
      started      = REXML::XPath.first( status, '//lst[@name="backup"]/str[@name="startTime"]' ).text
      basename     = Time.parse( started ).strftime( 'snapshot.%Y%m%d%H%M%S' )
      path         = REXML::XPath.first( status, '//lst[@name="details"]/str[@name="indexPath"]' ).text
      snapshot_dir = "#{path}/../#{basename}"
      dest_file    = "#{basename}.tar.gz"

      raise "Backup Directory: #{snapshot_dir} doesn't exist!" unless File.directory?( snapshot_dir )
      Dir.mktmpdir do |temp_dir|
        output = `tar -c -z -C #{snapshot_dir}/../ -f #{dest_file} #{basename}/  2>&1`
        if 0 == $?.exitstatus
          DC::Store::AssetStore.new.save_solr_backup( basename, dest_file )
          FileUtils.rm_rf snapshot_dir
          Rails.logger.info "Created sucessful backup of solr databse, saved to: #{dest_file}"
        else
          raise "Tar failed to compress backup: #{output}"
        end
      end

    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    true
  end

  private

  def perform_solr_request( command )
    ( host, port ) = solr_config
    resp = Net::HTTP.get_response( URI.parse("http://#{host}:#{port}/solr/replication?command=#{command}" ))
    raise resp.body unless resp.kind_of? Net::HTTPSuccess
    return REXML::Document.new( resp.body )
  end

  def solr_config
    return @solr_config_data if @solr_config_data
    config = YAML::load(ERB.new( File.read( RAILS_ROOT + '/' + File.dirname(__FILE__)+'/../../config/sunspot.yml' )).result)
    @solr_config_data = config[ Rails.env ]['solr'].values_at( 'hostname', 'port' )
  end

end
