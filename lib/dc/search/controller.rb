module DC
  module Search

    module Controller

      def perform_search
        opts          = {}
        opts[:facets] = true if params[:facets]
        opts.merge!({:account => current_account, :organization => current_organization}) if logged_in?
        @query        = DC::Search::Parser.new.parse(params[:q] || '')
        @query.page   = params[:page] ? params[:page].to_i : 1
        @documents    = Document.search(@query, opts).results
      end

    end

  end
end