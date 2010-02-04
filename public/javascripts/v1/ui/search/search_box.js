// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = dc.View.extend({

  PAGE_MATCHER : (/\/p(\d+)$/),

  id            : 'search',
  className     : 'accounts_tab_hidden',
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

  // Start a search for a query string, updating the page URL.
  search : function(query, pageNumber) {
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    if (project) project.view.showOpen();
    var sectionName = Inflector.truncate(projectName || query, 30);
    var section = {name : sectionName, callback : function(){ dc.app.searchBox.search(query); }};
    if (dc.app.navigation) dc.app.navigation.tab('search', {silent : true, section : section});
    $(document.body).setMode('active', 'search');
    var page = pageNumber <= 1 ? null : pageNumber;
    this.value(query);
    this.fragment = 'search/' + encodeURIComponent(query);
    dc.history.save(this.fragment + (page ? '/p' + page : ''));
    $('#document_list_container .documents').html('');
    this.outstandingSearch = true;
    dc.ui.spinner.show('searching');
    if (dc.app.toolbar) dc.app.toolbar.hide();
    var params = {q : query};
    if (page) params.page = page;
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
    var page = null;
    var pageMatch = hash.match(this.PAGE_MATCHER);
    if (pageMatch) {
      var page = pageMatch[1];
      hash = hash.replace(this.PAGE_MATCHER, '');
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
    dc.app.navigation.tab('dashboard');
  },

  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function(empty) {
    if (empty) $(document.body).setMode('empty', 'search');
    dc.ui.spinner.hide();
    this.outstandingSearch = false;
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
    $('#document_list_container').html((new dc.ui.DocumentList({set : Documents})).render().el);
    Documents.each(function(el) {
      $('#document_list_container .documents').append((new dc.ui.DocumentTile(el)).render().el);
    });
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