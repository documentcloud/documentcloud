// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = dc.View.extend({

  PAGE_MATCHER        : (/\/p(\d+)$/),
  CONNECTIONS_MATCHER : (/\/connections\/(\w+)$/),

  id            : 'search',
  fragment      : null,

  callbacks : {
    '#search_box.keydown': 'maybeSearch',
    '#search_box.search':  'searchEvent',
    '#search_type.click':  '_setScope'
  },

  // Creating a new SearchBox registers #search page fragments.
  constructor : function(options) {
    this.base(options);
    this.outstandingSearch = false;
    _.bindAll(this, 'loadSearchResults', 'searchByHash', 'clearSearch');
    dc.history.register(/^#search\//, this.searchByHash);
    dc.history.register(/^#dashboard$/, this.clearSearch);
  },

  render : function() {
    $(this.el).append(JST.search_box({}));
    this.box  = $('#search_box', this.el);
    this.menu = $('#search_type', this.el);
    $(document.body).setMode('no', 'search');
    this.setCallbacks();
    return this;
  },

  // Shortcut to the searchbox's value.
  value : function(query) {
    return this.box.val(query);
  },

  urlFragment : function() {
    return this.fragment + (this.page ? '/p' + this.page : '');
  },

  // Start a search for a query string, updating the page URL.
  search : function(query, pageNumber) {
    dc.app.toolbar.connectionsMenu.deactivate();
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    project ? project.view.showOpen() : dc.ui.Project.clearSelection();
    var sectionName = Inflector.truncate(projectName || query, 30);
    var section = {name : sectionName, callback : function(){ dc.app.searchBox.search(query); }};
    // if (dc.app.navigation) dc.app.navigation.tab('search', {silent : true, section : section});
    $(document.body).setMode('active', 'search');
    this.page = pageNumber <= 1 ? null : pageNumber;
    this.value(query);
    this.fragment = 'search/' + encodeURIComponent(query);
    dc.history.save(this.urlFragment());
    Documents.refresh();
    this.outstandingSearch = true;
    dc.ui.spinner.show('searching');
    if (dc.app.toolbar) dc.app.toolbar.hide();
    var params = {q : query};
    if (this.page) params.page = this.page;
    var url = query.match(/notes:/) ? '/search/notes.json' : '/search/documents.json';
    $.get(url, params, this.loadSearchResults, 'json');
  },

  // Ensure a given prefix for the search, used to scope searches down to
  // a specific qualifier.
  scopeSearch : function(prefix) {
    var search = this.value().replace(/^(organization|documents):\s+\S+ /, '');
    this.value(prefix + search);
  },

  // When searching by the URL's hash value, we need to unescape first.
  searchByHash : function(hash) {
    var page = null, connection = null;
    var pageMatch = hash.match(this.PAGE_MATCHER);
    if (pageMatch) {
      var page = pageMatch[1];
      hash = hash.replace(this.PAGE_MATCHER, '');
    }
    var connMatch = hash.match(this.CONNECTIONS_MATCHER);
    if (connMatch) {
      this._connection = connMatch[1];
      hash = hash.replace(this.CONNECTIONS_MATCHER, '');
    }
    this.search(decodeURIComponent(hash), page);
  },

  // Callback fired on key press in the search box. We search when they hit
  // return.
  maybeSearch : function(e) {
    var query = this.value();
    if (!this.outstandingSearch && e.keyCode == 13) {
      query ? this.search(query) : this.clearSearch();;
    }
  },

  // Webkit knows how to fire a real "search" event.
  searchEvent : function(e) {
    var query = this.value();
    if (!query) return this.clearSearch();
    if (!this.outstandingSearch && query) this.search(query);
  },

  clearSearch : function() {
    this.value('');
    $(document.body).setMode('no', 'search');
    dc.ui.Project.clearSelection();
    dc.history.save('dashboard');
  },

  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function(empty) {
    if (empty) $(document.body).setMode('empty', 'search');
    dc.ui.spinner.hide();
    this.outstandingSearch = false;
    if (this._connection) {
      Documents.selectAll();
      dc.app.visualizer.open(this._connection);
      this._connection = null;
    }
  },

  // After the initial search results come back, send out a request for the
  // associated metadata, as long as something was found. Think about returning
  // the metadata right alongside the document JSON.
  loadSearchResults : function(resp) {
    dc.app.paginator.setQuery(resp.query);
    Metadata.refresh();
    Documents.refresh(_.map(resp.documents, function(m){
      return new dc.model.Document(m);
    }));
    return this.doneSearching(resp.documents.length == 0);
  },

  _setScope : function(e) {
    var scope = null;
    switch (this.menu.val()) {
      case 'all':           scope = '';                                                    break;
      case 'account':       scope = 'documents: ' + Accounts.current().get('email') + ' '; break;
      case 'organization':  scope = 'organization: ' + dc.app.organization.slug + ' ';     break;
    }
    this.scopeSearch(scope);
  }

});