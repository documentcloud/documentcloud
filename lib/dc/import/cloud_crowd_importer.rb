module DC
  module Import

    class CloudCrowdImporter

      DEFAULT_OPTIONS = {
        'organization_id' => 0,
        'account_id'      => 0,
        'source'          => 'Unknown',
        'access'          => DC::Access::PUBLIC
      }

      def import(urls, options={})
        RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
          'action'  => 'document_import',
          'inputs'  => urls,
          'options' => DEFAULT_OPTIONS.merge(options),
          'callback_url' => "#{DC_CONFIG['server_root']}/import/cloud_crowd"
        }.to_json})
      end

    end

  end
end