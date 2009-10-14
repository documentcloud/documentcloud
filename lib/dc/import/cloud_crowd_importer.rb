module DC
  module Import
    
    class CloudCrowdImporter
      
      # TODO: Figure out how we're going to specify where the callback URL lives.
      def import(urls, opts={})
        RestClient.post(
          options = {
            'organization_id' => 0, 
            'account_id'      => 0, 
            'access'          => DC::Access::PUBLIC
          }.merge(opts)
          DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
            'action'  => 'document_import',
            'inputs'  => urls,
            'options' => options,
            'callback_url' => "#{DC_CONFIG['server_root']}/import/cloud_crowd"
          }.to_json}
        )
      end
      
    end
    
  end
end