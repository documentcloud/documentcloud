module DC
  module Import
    
    class CloudCrowdImporter
      
      # TODO: Figure out how we're going to specify where the callback URL lives.
      def import(urls)
        RestClient.post(
          DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
            'action'  => 'document_import',
            'inputs'  => urls,
            'options' => {},
            'callback_url' => "#{DC_CONFIG['server_root']}/import/cloud_crowd"
          }.to_json}
        )
      end
      
    end
    
  end
end