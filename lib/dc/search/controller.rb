module DC
  module Search

    module Controller

      API_OPTIONS = {:sections => false, :annotations => false, :access => true, :contributor => false}

      def perform_search(opts={})
        opts[:facet]      = params[:facet]
        opts.merge!({:account => current_account, :organization => current_organization}) if logged_in?
        @query            = DC::Search::Parser.new.parse(params[:q] || '')
        @query.per_page   = per_page
        @query.order      = params[:order] || DEFAULT_ORDER
        @query.page       = params[:page].to_i > 0 ? params[:page].to_i : 1
        search_results    = Document.search(@query, opts)
        @documents        = search_results.results
      end


      protected

      def per_page
        num = (params[:per_page] && params[:per_page].to_i) || DEFAULT_PER_PAGE
        num = DEFAULT_PER_PAGE if num > MAX_PER_PAGE
        num
      end

    end

  end
end
