module DC
  module Search

    module Controller

      def perform_search
        opts                  = {}
        opts[:include_facets] = true if params[:include_facets]
        opts[:facet]          = params[:facet]
        opts.merge!({:account => current_account, :organization => current_organization}) if logged_in?
        @query            = DC::Search::Parser.new.parse(params[:q] || '')
        @query.page_size  = params[:page_size] ? params[:page_size].to_i : DEFAULT_PAGE_SIZE
        @query.page       = params[:page] ? params[:page].to_i : 1
        @documents        = Document.search(@query, opts).results
      end

    end

  end
end