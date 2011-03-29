module DC
  module Import

    class CloudCrowdImporter

      DEFAULT_OPTIONS = {
        'organization_id'   => 0,
        'account_id'        => 0,
        'source'            => 'Unknown',
        'access'            => DC::Access::PRIVATE
      }

      def import(urls, options={}, large=false)
        options = options.stringify_keys
        RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
          'action'  => large ? 'large_document_import' : 'document_import',
          'inputs'  => urls,
          'options' => DEFAULT_OPTIONS.merge(options),
          'callback_url' => "#{DC.server_root(:ssl => false)}/import/cloud_crowd"
        }.to_json})
      end

    end

  end
end