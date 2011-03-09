// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = Backbone.View.extend({

  // Error messages to display when your search returns no results.
  NO_RESULTS : {
    project   : "This project does not contain any documents.",
    account   : "This account does not have any documents.",
    group     : "This organization does not have any documents.",
    published : "This account does not have any published documents.",
    annotated : "There are no annotated documents.",
    search    : "Your search did not match any documents.",
    all       : "There are no documents.",
    related   : "There are no documents related to this document."
  },

  id  : 'search',
  
  PREFIXES : ['project', 'text', 'account', 'document'],

  events : {
    'keydown #search_box'       : 'maybeSearch',
    'search #search_box'        : 'searchEvent',
    'focus #search_box'         : 'addFocus',
    'blur #search_box'          : 'removeFocus',
    'click .cancel_search'      : 'cancelSearch',
    'click #search_box_wrapper' : 'focusSearch'
  },

  // Creating a new SearchBox registers #search page fragments.
  constructor : function(options) {
    Backbone.View.call(this, options);
    _.bindAll(this, 'hideSearch');
  },

  render : function() {
    $(this.el).append(JST['workspace/search_box']({}));
    this.box      = this.$('#search_box');
    this.titleBox = this.$('#title_box_inner');
    _.bindAll(this, 'autocompletePrefixCheck', 'autocompletePrefixSuccess');
    $(document.body).setMode('no', 'search');
    this.box.autoGrowInput();
    this.autocomplete = new dc.ui.Autocomplete({
      input           : this.box, 
      checkCallback   : this.autocompletePrefixCheck, 
      successCallback : this.autocompletePrefixSuccess
    });
    return this;
  },

  autocompletePrefixCheck : function(partial, callback) {
    var values = [
      'Account',
      'Organization',
      'Project',
      'Filter',
      'Text'
    ];
    callback(values, partial);
  },
  
  autocompletePrefixSuccess : function() {
    
  },
  
  // Shortcut to the searchbox's value.
  value : function(query) {
    if (query == null) return this.getQuery();
    return this.setQuery(query);
  },
  
  getQuery : function() {
    var query = "";
    if (dc.app.searchBox.facetViews) {
      _.each(dc.app.searchBox.facetViews, function(view) {
        query += view.serialize();
      });
      query += this.box.val();
    }
    
    return query;
  },
  
  setQuery : function(query) {
    console.log(['query', query]);
    var facets = this.extractFacets(query);
    this.renderFacets(facets);
    query = this.pareQuery(query);
    if (query) this.renderFacet('text', query);
    this.box.val('');
  },

  hideSearch : function() {
    $(document.body).setMode(null, 'search');
  },

  showDocuments : function() {
    $(document.body).setMode('active', 'search');
    var query = this.value();
    var facets = this.extractFacets(query);
    this.entitle(query, facets);
    dc.app.organizer.highlight(query);
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
    if (!dc.app.searcher.flags.outstandingSearch && e.keyCode == 13) return this.searchEvent(e);
  },

  // Webkit knows how to fire a real "search" event.
  searchEvent : function(e) {
    var query = this.value();
    if (!dc.app.searcher.flags.outstandingSearch && query) dc.app.searcher.search(query);
  },

  entitle : function(query) {
    var title = dc.model.DocumentSet.entitle(query);
    this.titleBox.html(title);
  },

  // Renders each facet as a searchFacet view.
  renderFacets : function(facets) {
    this.$('.search_facets').empty();
    this.facetViews = [];
    if (facets.projectName)     this.renderFacet('project', facets.projectName);
    if (facets.accountSlug)     this.renderFacet('account', facets.accountSlug);
    if (facets.groupName)       this.renderFacet('group', facets.groupName);
    if (facets.filter)          this.renderFacet('filter', facets.filter);
    if (facets.entities.length) console.log(['entities', facets.entities]);
  },
  
  // Render a single facet, using its category and query value.
  renderFacet : function(category, facetQuery) {
    var view = new dc.ui.SearchFacet({
      category   : category,
      facetQuery : Inflector.trim(facetQuery)
    });
    
    this.facetViews.push(view);
    this.$('.search_facets').append(view.render().el);
  },
  
  pareQuery : function(query) {
    query = dc.app.SearchParser.removeProject(query);
    query = dc.app.SearchParser.removeAccount(query);
    query = dc.app.SearchParser.removeGroup(query);
    query = dc.app.SearchParser.removeFilter(query);
    return Inflector.trim(query);
  },
  
  // Takes a search query and return all of the facets found in an object.
  extractFacets : function(query) {
    var projectName   = dc.app.SearchParser.extractProject(query);
    var accountSlug   = dc.app.SearchParser.extractAccount(query);
    var groupName     = dc.app.SearchParser.extractGroup(query);
    var filter        = dc.app.SearchParser.extractFilter(query);
    var entities      = dc.app.SearchParser.extractEntities(query);
    var facets        = {
      projectName : projectName,
      accountSlug : accountSlug,
      groupName   : groupName,
      filter      : filter,
      entities    : entities
    };
    
    return facets;
  },
  
  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    var count     = dc.app.paginator.query.total;
    var documents = Inflector.pluralize('Document', count);
    var query     = this.value();
    if (dc.app.searcher.flags.related) {
      this.titleBox.text(count + ' ' + documents + ' Related to "' + Inflector.truncate(dc.app.searcher.relatedDoc.get('title'), 100) + '"');
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
    dc.app.scroller.checkLater();
  },
  
  focusNextFacet : function(currentView, direction) {
    var currentFacetIndex;
    var viewsCount = this.facetViews.length;
    
    _.each(this.facetViews, function(facetView, i) {
      if (currentView == facetView) {
        currentFacetIndex = i;
      }
    });
    
    var next = currentFacetIndex + direction;
    if (next > viewsCount-1) next = 0;
    if (next < 0) next = viewsCount-1;
    this.facetViews[next].enableEdit();
  },

  blur : function() {
    this.box.blur();
  },

  focusSearch : function(e) {
    if ($(e.target).is('#search_box_wrapper')) {
      this.box.focus();
    }
  },
  
  addFocus : function() {
    Documents.deselectAll();
    this.$('.search').addClass('focus');
  },

  removeFocus : function() {
    this.$('.search').removeClass('focus');
  }

});