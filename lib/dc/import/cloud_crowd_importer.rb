module DC
  module Import

    class CloudCrowdImporter
      include DC::Access

      DEFAULT_OPTIONS = {
        'organization_id'   => 0,
        'account_id'        => 0,
        'source'            => 'Unknown',
        'access'            => PRIVATE
      }

      def import(urls, options={}, large=false)
        options = DEFAULT_OPTIONS.merge options.stringify_keys
        options['access'] = PRIVATE if options['access'] == PENDING
        RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
          'action'  => large ? 'large_document_import' : 'document_import',
          'inputs'  => urls,
          'options' => options,
          'callback_url' => "#{DC.server_root(:ssl => false)}/import/cloud_crowd"
        }.to_json})
      end

    end

  end
end
