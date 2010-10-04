// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = Backbone.View.extend({

  // Error messages to display when your search returns no results.
  NO_RESULTS : {
    project   : "This project does not contain any documents.",
    account   : "This account has not uploaded any documents.",
    group     : "This organization has not uploaded any documents.",
    published : "This account does not have any published documents.",
    search    : "Your search did not match any documents.",
    all       : "There are no documents.",
    related   : "There are no documents related to this document."
  },

  id  : 'search',

  callbacks : {
    '#search_box.keydown':  'maybeSearch',
    '#search_box.search':   'searchEvent',
    '#search_box.focus':    '_addFocus',
    '#search_box.blur':     '_removeFocus',
    '.cancel_search.click': 'cancelSearch'
  },

  // Creating a new SearchBox registers #search page fragments.
  constructor : function(options) {
    Backbone.View.call(this, options);
    this.searcher = dc.app.searcher;
    _.bindAll(this, 'hideSearch');
  },

  render : function() {
    $(this.el).append(JST['workspace/search_box']({}));
    this.box      = this.$('#search_box');
    this.titleBox = this.$('#title_box_inner');
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
    var projectName   = dc.app.SearchParser.extractProject(query);
    var accountName   = dc.app.SearchParser.extractAccount(query);
    var groupName     = dc.app.SearchParser.extractGroup(query);
    var published     = dc.app.SearchParser.extractPublished(query);
    if (projectName) {
      title = projectName;
    } else if (accountName == Accounts.current().get('slug')) {
      ret = published ? 'published_documents' : 'your_documents';
    } else if (groupName == dc.app.organization.slug) {
      ret = 'org_documents';
    } else {
      ret = 'all_documents';
    }
    title = title || dc.model.Project.topLevelTitle(ret);
    this.titleBox.html(title);
  },

  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    var count     = dc.app.paginator.query.total;
    var documents = Inflector.pluralize('Document', count);
    var query     = this.value();
    if (dc.app.searcher.flags.related) {
      this.titleBox.text(count + ' ' + documents + ' Related to "' + Inflector.truncate(this.searcher.relatedDoc.get('title'), 100) + '"');
    } else if (dc.app.searcher.flags.specific) {
      this.titleBox.text(count + ' ' + documents);
    } else if (dc.app.SearchParser.searchType(query) == 'search') {
      var quote  = !!dc.app.SearchParser.extractProject(query);
      var suffix = ' in ' + (quote ? '“' : '') + this.titleBox.html() + (quote ? '”' : '');
      var prefix = count ? count + ' ' + Inflector.pluralize('Result', count) : 'No Results';
      this.titleBox.html(prefix + suffix);
    }
    if (count <= 0) {
      $(document.body).setMode('empty', 'search');
      var searchType = dc.app.SearchParser.searchType(this.value());
      $('#no_results .explanation').text(this.NO_RESULTS[searchType]);
    }
    dc.ui.spinner.hide();
  },

  _addFocus : function() {
    this.$('#search_box').addClass('focus');
  },

  _removeFocus : function() {
    this.$('#search_box').removeClass('focus');
  }

});