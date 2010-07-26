module DC
  module Search

    module Controller

      def perform_search(opts={})
        opts[:facet]      = params[:facet]
        opts.merge!({:account => current_account, :organization => current_organization}) if logged_in?
        @query            = DC::Search::Parser.new.parse(params[:q] || '')
        @query.page_size  = params[:page_size] ? params[:page_size].to_i : DEFAULT_PAGE_SIZE
        @query.order      = params[:order] || DEFAULT_ORDER
        @query.page       = params[:page] ? params[:page].to_i : 1
        search_results    = Document.search(@query, opts)
        @documents        = search_results.results
        @related_document = search_results.related_document
      end

    end

  end
end