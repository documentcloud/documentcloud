module DC
  module Import
    
    class CloudCrowdImporter
      
      def import(urls, opts={})
        options = {
          'organization_id' => 0, 
          'account_id'      => 0, 
          'source'          => 'The New York Times', # FIXME FIXME
          'access'          => DC::Access::PUBLIC
        }.merge(opts)
        RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
            'action'  => 'document_import',
            'inputs'  => urls,
            'options' => options,
            'callback_url' => "#{DC_CONFIG['server_root']}/import/cloud_crowd"
        }.to_json})
      end
      
    end
    
  end
end