// The `dc.app.searcher` is the core controller for running document searches
// from the client side. It's main "view" is the `dc.ui.SearchBox`.
dc.controllers.Searcher = Backbone.Controller.extend({

  // Error messages to display when your search returns no results.
  NO_RESULTS : {
    project   : "This project does not contain any documents.",
    account   : "This account does not have any documents.",
    group     : "This organization does not have any documents.",
    related   : "There are no documents related to this document.",
    published : "This account does not have any published documents.",
    annotated : "There are no annotated documents.",
    search    : "Your search did not match any documents.",
    all       : "There are no documents."
  },

  PAGE_MATCHER  : (/\/p(\d+)$/),

  DOCUMENTS_URL : '/search/documents.json',

  FACETS_URL    : '/search/facets.json',

  fragment      : null,

  flags         : {},

  routes        : {
    'search/:query':         'searchByHash',
    'search/:query/p:page':  'searchByHash'
  },

  // Creating a new SearchBox registers #search page fragments.
  initialize : function() {
    this.searchBox = dc.app.searchBox;
    this.flags.hasEntities = false;
    this.currentSearch = null;
    this.titleBox = $('#title_box_inner');
    _.bindAll(this, '_loadSearchResults', '_loadFacetsResults', '_loadFacetResults',
      'loadDefault', 'loadFacets');
    dc.app.navigation.bind('tab:search', this.loadDefault);
  },

  urlFragment : function() {
    return this.fragment + (this.page ? '/p' + this.page : '');
  },

  // Load the default starting-point search.
  loadDefault : function(options) {
    options || (options = {});
    if (options.clear) {
      Documents.refresh();
      this.searchBox.value('');
    }
    if (this.currentSearch) return;
    if (!Documents.isEmpty()) {
      this.saveLocation(this.urlFragment());
      this.showDocuments();
    } else if (this.searchBox.value()) {
      this.search(this.searchBox.value());
    } else if (dc.account && dc.account.hasDocuments) {
      Accounts.current().openDocuments();
    } else if (Projects.first()) {
      Projects.first().open();
    } else if (options.showHelp && dc.account) {
      dc.app.navigation.open('help');
    } else {
      this.search('');
    }
  },

  // Paginate forwards or backwards in the search results.
  loadPage : function(page, callback) {
    page = page || this.page || 1;
    var max = dc.app.paginator.pageCount();
    if (page < 1) page = 1;
    if (page > max) page = max;
    this.search(this.searchBox.value(), page, callback);
  },

  // Quote a string if necessary (contains whitespace).
  quote : function(string) {
    return string.match(/\s/) ? '"' + string + '"' : string;
  },

  publicQuery : function() {
    var projectName;
    var query = this.box.value();

    // Swap out documents for short ids.
    query = query.replace(/(document: \d+)-\S+/g, '$1');

    // Swap out projects.
    var projects = [];
    var projectNames = VS.app.searchQuery.values('project');
    _.each(projectNames, function(projectName) {
      projects.push(Projects.find(projectName));
    });
    var query = VS.app.searchQuery.withoutCategory('project');
    query = _.map(projects, function(p) { return 'projectid: ' + p.slug(); }).join(' ') + ' ' + query;

    // Swap out documents for short ids.
    query = query.replace(/(document: \d+)-\S+/g, '$1');

    return query;
  },

  queryText : function() {
    return VS.app.searchQuery.find('text');
  },

  // Start a search for a query string, updating the page URL.
  search : function(query, pageNumber, callback) {
    dc.ui.spinner.show();
    dc.app.navigation.open('search');
    if (this.currentSearch) this.currentSearch.abort();
    this.searchBox.value(query);
    this.flags.related  = query.indexOf('related:') >= 0;
    this.flags.specific = query.indexOf('document:') >= 0;
    this.flags.hasEntities = false;
    this.page = pageNumber <= 1 ? null : pageNumber;
    this.fragment = 'search/' + encodeURIComponent(query);
    this.populateRelatedDocument();
    this.showDocuments();
    this.saveLocation(this.urlFragment());
    Documents.refresh();
    this._afterSearch = callback;
    var params = _.extend(dc.app.paginator.queryParams(), {q : query});
    if (this.flags.related && !this.relatedDoc) params.include_source_document = true;
    if (dc.app.navigation.isOpen('entities'))   params.include_facets = true;
    if (this.page)                              params.page = this.page;
    this.currentSearch = $.ajax({
      url:      this.DOCUMENTS_URL,
      data:     params,
      success:  this._loadSearchResults,
      error:    function(req, textStatus, errorThrown) {
        if (req.status == 403) Accounts.forceLogout();
      },
      dataType: 'json'
    });
  },

  showDocuments : function() {
    var query       = this.searchBox.value();
    var title       = dc.model.DocumentSet.entitle(query);
    var projectName = VS.app.searchQuery.find('project');
    var groupName   = VS.app.searchQuery.find('group');

    $(document.body).setMode('active', 'search');
    this.titleBox.html(title);
    dc.app.organizer.highlight(projectName, groupName);
  },

  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    var count      = dc.app.paginator.query.total;
    var documents  = dc.inflector.pluralize('Document', count);
    var searchType = this.searchType();

    if (this.flags.related) {
      this.titleBox.text(count + ' ' + documents + ' Related to "' + dc.inflector.truncate(this.relatedDoc.get('title'), 100) + '"');
    } else if (this.flags.specific) {
      this.titleBox.text(count + ' ' + documents);
    } else if (searchType == 'search') {
      var quote  = VS.app.searchQuery.has('project');
      var suffix = ' in ' + (quote ? '“' : '') + this.titleBox.html() + (quote ? '”' : '');
      var prefix = count ? count + ' ' + dc.inflector.pluralize('Result', count) : 'No Results';
      this.titleBox.html(prefix + suffix);
    }
    if (count <= 0) {
      $(document.body).setMode('empty', 'search');
      var explanation = this.NO_RESULTS[searchType] || this.NO_RESULTS['search'];
      $('#no_results .explanation').text(explanation);
    }
    dc.ui.spinner.hide();
    dc.app.scroller.checkLater();
  },

  searchType : function() {
    var single   = false;
    var multiple = false;

    VS.app.searchQuery.each(function(facet) {
      var category = facet.get('category');
      var value    = facet.get('value');

      if (value) {
        if (!single && !multiple) {
          single = category;
        } else {
          multiple = true;
          single = false;
        }
      }
    });

    if (single == 'filter') {
      return VS.app.searchQuery.first().get('value');
    } else if (single == 'projectid') {
      return 'project';
    } else if (_.contains(['project', 'group', 'account'], single)) {
      return single;
    } else if (!single && !multiple) {
      return 'all';
    }

    return 'search';
  },

  loadFacets : function() {
    if (this.flags.hasEntities) return;
    var query = this.searchBox.value() || '';
    dc.ui.spinner.show();
    this.currentSearch = $.get(this.FACETS_URL, {q: query}, this._loadFacetsResults, 'json');
  },

  loadFacet : function(facet) {
    dc.ui.spinner.show();
    this.currentSearch = $.get(this.FACETS_URL, {q : this.searchBox.value(), facet : facet}, this._loadFacetResults, 'json');
  },

  // When searching by the URL's hash value, we need to unescape first.
  searchByHash : function(query, page) {
    _.defer(_.bind(function() {
      this.search(decodeURIComponent(query), page && parseInt(page, 10));
    }, this));
  },

  // Toggle a query fragment in the search.
  toggleSearch : function(category, value) {
    if (VS.app.searchQuery.has(category)) {
      this.removeFromSearch(category);
    } else {
      this.addToSearch(category, value);
    }
  },

  // Add a query fragment to the search and search again, if it's not already
  // present in the current search.
  addToSearch : function(category, value, callback) {
    if (VS.app.searchQuery.has(category, value)) return;
    VS.app.searchQuery.add({category: category, value: value});
    var query = VS.app.searchQuery.value();
    this.search(query, null, callback);
  },

  // Remove a query fragment from the search and search again, only if it's
  // present in the current search.
  removeFromSearch : function(category) {
    var query = VS.app.searchQuery.withoutCategory(category);
    this.search(query);
    return true;
  },

  populateRelatedDocument : function() {
    var relatedFacet = VS.app.searchQuery.find('related');
    var id = parseInt(relatedFacet && relatedFacet.get('value'), 10);
    this.relatedDoc = Documents.get(id) || null;
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
    var docs = resp.documents;
    for (var i = 0, l = docs.length; i < l; i++) docs[i].index = i;
    Documents.refresh(docs);
    if (this.flags.related && !this.relatedDoc) {
      this.relatedDoc = new dc.model.Document(resp.source_document);
    }
    this.doneSearching();
    this.currentSearch = null;
    if (this._afterSearch) this._afterSearch();
  },

  _loadFacetsResults : function(resp) {
    dc.app.workspace.entityList.renderFacets(resp.facets, 5, resp.query.total);
    dc.ui.spinner.hide();
    this.currentSearch = null;
    this.flags.hasEntities = true;
  },

  _loadFacetResults : function(resp) {
    dc.app.workspace.entityList.mergeFacets(resp.facets, 500, resp.query.total);
    dc.ui.spinner.hide();
    this.currentSearch = null;
  }

});
