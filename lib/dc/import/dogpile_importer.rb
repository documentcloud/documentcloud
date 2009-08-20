module DC
  module Import
    
    class DogpileImporter
      
      # TODO: Figure out how we're going to specify where the callback URL lives.
      def import(urls)
        RestClient.post(
          DC::CONFIG['dogpile_server'] + '/jobs', {:json => {
            'action'  => 'document_cloud_import',
            'inputs'  => urls,
            'options' => {},
            'callback_url' => 'http://localhost:3000/import/dogpile'
          }.to_json}
        )
      end
      
    end
    
  end
end