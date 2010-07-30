// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = dc.View.extend({

  // Error messages to display when your search returns no results.
  NO_RESULTS : {
    project : "This project does not contain any documents.",
    account : "This account has not uploaded any documents.",
    search  : "Your search did not match any documents.",
    related : "There are no documents related to this document."
  },

  id  : 'search',

  callbacks : {
    '#search_box.keydown':  'maybeSearch',
    '#search_box.search':   'searchEvent',
    '.cancel_search.click': 'cancelSearch'
  },

  // Creating a new SearchBox registers #search page fragments.
  constructor : function(options) {
    this.base(options);
    this.searcher = dc.app.searcher;
    _.bindAll(this, 'hideSearch');
  },

  render : function() {
    $(this.el).append(JST['workspace/search_box']({}));
    this.box      = $('#search_box', this.el);
    this.titleBox = $('#title_box', this.el);
    $(document.body).setMode('no', 'search');
    this.setCallbacks();
    $('#cloud_edge').click(function(){ window.location = '/home'; });
    return this;
  },

  // Shortcut to the searchbox's value.
  value : function(query) {
    return this.box.val(query);
  },

  hideSearch : function() {
    $(document.body).setMode(null, 'search');
  },

  showDocuments : function() {
    $(document.body).setMode('active', 'search');
    var query = this.value();
    this.entitle(query);
    dc.ui.Project.highlight(query);
  },

  startSearch : function() {
    dc.ui.spinner.show();
    dc.app.paginator.hide();
    _.defer(dc.app.toolbar.checkFloat);
  },

  cancelSearch : function() {
    this.value('');
  },

  // Callback fired on key press in the search box. We search when they hit
  // return.
  maybeSearch : function(e) {
    var query = this.value();
    if (!this.searcher.flags.outstandingSearch && e.keyCode == 13) this.searcher.search(query);
  },

  // Webkit knows how to fire a real "search" event.
  searchEvent : function(e) {
    var query = this.value();
    if (!this.searcher.flags.outstandingSearch && query) this.searcher.search(query);
  },

  entitle : function(query) {
    var title, ret;
    var projectName = dc.app.SearchParser.extractProject(query);
    var accountName = dc.app.SearchParser.extractAccount(query);
    var groupName   = dc.app.SearchParser.extractGroup(query);
    if (projectName) {
      title = projectName;
    } else if (accountName == Accounts.current().get('email')) {
      ret = 'your_documents';
    } else if (groupName == dc.app.organization.slug) {
      ret = 'org_documents';
    } else {
      ret = 'all_documents';
    }
    title = title || dc.model.Project.topLevelTitle(ret);
    this.titleBox.text(title);
  },

  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function(empty) {
    if (dc.app.searcher.flags.related) {
      this.titleBox.text(Inflector.pluralize('Document', dc.app.paginator.query.total) +
      ' Related to "' + Inflector.truncate(this._relatedDoc.get('title'), 100) + '"');
    }
    if (empty) {
      $(document.body).setMode('empty', 'search');
      var searchType = dc.app.SearchParser.searchType(this.value());
      $('#no_results .explanation').text(this.NO_RESULTS[searchType]);
    }
    dc.ui.spinner.hide();
  }

});