// The `dc.app.searcher` is the core controller for running document searches
// from the client side. It's main "view" is the dc.ui.SearchBox.
dc.app.searcher = new dc.Model();
dc.app.searcher.extend({

  PAGE_MATCHER  : (/\/p(\d+)$/),

  DOCUMENTS_URL : '/search/documents.json',

  FACETS_URL    : '/search/facets.json',

  fragment      : null,

  flags         : {},

  // Creating a new SearchBox registers #search page fragments.
  initialize : function() {
    this.box = dc.app.searchBox;
    this.flags.hasEntities = false;
    this.flags.outstandingSearch = false;
    _.bindAll(this, '_loadSearchResults', '_loadFacetsResults', '_loadFacetResults',
      'searchByHash', 'loadDefault', 'loadFacets');
    dc.history.register(/^#search\//, this.searchByHash);
    dc.app.navigation.bind('tab:search', this.loadDefault);
  },

  urlFragment : function() {
    return this.fragment + (this.page ? '/p' + this.page : '');
  },

  // Load the default starting-point search.
  loadDefault : function(options) {
    options = options || {};
    if (options.clear) {
      Documents.refresh();
      this.box.value('');
    }
    if (!Documents.empty()) {
      dc.history.save(this.urlFragment());
      this.box.showDocuments();
    } else if (this.box.value()) {
      this.search(this.box.value());
    } else if (dc.app.hasDocuments) {
      Accounts.current().openDocuments();
    } else if (Projects.first()) {
      Projects.first().open();
    } else if (options.showHelp) {
      dc.app.navigation.open('help');
    } else {
      this.search('');
    }
  },

  // Start a search for a query string, updating the page URL.
  search : function(query, pageNumber, callback) {
    dc.app.navigation.open('search');
    this.box.value(query);
    this.flags.related  = query.indexOf('related:') >= 0;
    this.flags.specific = query.indexOf('document:') >= 0;
    this.flags.hasEntities = false;
    this.page = pageNumber <= 1 ? null : pageNumber;
    this.fragment = 'search/' + encodeURIComponent(query);
    this.populateRelatedDocument();
    this.box.showDocuments();
    dc.history.save(this.urlFragment());
    Documents.refresh();
    this.flags.outstandingSearch = true;
    this._afterSearch = callback;
    this.box.startSearch();
    var params = _.extend(dc.app.paginator.queryParams(), {q : query});
    if (this.flags.related && !this.relatedDoc) params.include_source_document = true;
    if (dc.app.navigation.isOpen('entities'))   params.include_facets = true;
    if (this.page)                              params.page = this.page;
    $.ajax({
      url:      this.DOCUMENTS_URL,
      data:     params,
      success:  this._loadSearchResults,
      error:    Accounts.forceLogout,
      dataType: 'json'
    });
  },

  loadFacets : function() {
    if (this.flags.hasEntities) return;
    var query = this.box.value() || '';
    dc.ui.spinner.show();
    this.flags.outstandingSearch = true;
    $.get(this.FACETS_URL, {q: query}, this._loadFacetsResults, 'json');
  },

  loadFacet : function(facet) {
    dc.ui.spinner.show();
    this.flags.outstandingSearch = true;
    $.get(this.FACETS_URL, {q : this.box.value(), facet : facet}, this._loadFacetResults, 'json');
  },

  // When searching by the URL's hash value, we need to unescape first.
  searchByHash : function(hash, callback) {
    var page = null, connection = null;
    var pageMatch = hash.match(this.PAGE_MATCHER);
    if (pageMatch) {
      var page = pageMatch[1];
      hash = hash.replace(this.PAGE_MATCHER, '');
    }
    this.search(decodeURIComponent(hash), page, callback);
  },

  // Add a query fragment to the search and search again, if it's not already
  // present in the current search.
  addToSearch : function(fragment, callback) {
    var val = this.box.value();
    if (val.toLowerCase().match(fragment.toLowerCase())) return;
    this.box.value(val = (val + " " + fragment));
    this.search(val, null, callback);
  },

  // Remove a query fragment from the search and search again, only if it's
  // present in the current search.
  removeFromSearch : function(regex) {
    var val = this.box.value();
    if (!val.match(regex)) return;
    var next = val.replace(regex, '');
    if (next == val) return false;
    this.box.value(next);
    this.search(next);
    return true;
  },

  populateRelatedDocument : function() {
    this.relatedDoc = null;
    var id = parseInt(dc.app.SearchParser.extractRelatedDocId(this.box.value()), 10);
    this.relatedDoc = Documents.get(id);
  },

  viewEntities : function(docs) {
    dc.app.navigation.open('entities', true);
    this.search(_.map(docs, function(doc){ return 'document: ' + doc.canonicalId(); }).join(' '));
  },

  // After the initial search results come back, send out a request for the
  // associated metadata, as long as something was found. Think about returning
  // the metadata right alongside the document JSON.
  _loadSearchResults : function(resp) {
    dc.app.paginator.setQuery(resp.query, this);
    if (resp.facets) this._loadFacetsResults(resp);
    Documents.refresh(_.map(resp.documents, function(m, i){
      m.index = i;
      return new dc.model.Document(m);
    }));
    if (this.flags.related && !this.relatedDoc) {
      this.relatedDoc = new dc.model.Document(resp.source_document);
    }
    this.box.doneSearching(resp.documents.length == 0);
    this.flags.outstandingSearch = false;
    if (this._afterSearch) this._afterSearch();
  },

  _loadFacetsResults : function(resp) {
    dc.app.workspace.organizer.renderFacets(resp.facets, 5, resp.query.total);
    dc.ui.spinner.hide();
    this.flags.outstandingSearch = false;
    this.flags.hasEntities = true;
  },

  _loadFacetResults : function(resp) {
    dc.app.workspace.organizer.mergeFacets(resp.facets, 500, resp.query.total);
    dc.ui.spinner.hide();
    this.flags.outstandingSearch = false;
  }

});
