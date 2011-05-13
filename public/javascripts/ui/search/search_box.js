// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = Backbone.View.extend({

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

  id  : 'search',
  
  events : {
    'click .search_glyph'       : 'showFacetCategoryMenu',
    'click .cancel_search_box'  : 'cancelSearch',
    'click #search_box_wrapper' : 'focusSearch',
    'click #search_button'      : 'searchEvent'
  },

  // Creating a new SearchBox registers #search page fragments.
  constructor : function(options) {
    Backbone.View.call(this, options);
    _.bindAll(this, 'hideSearch', 'renderFacets');
    SearchQuery.bind('refresh', this.renderFacets);
  },

  render : function() {
    $(this.el).append(JST['workspace/search_box']({}));
    this.titleBox = this.$('#title_box_inner');
    $(document.body).setMode('no', 'search');
        
    return this;
  },
  
  removeFacet : function(view) {
    this.facetViews = _.without(this.facetViews, view);
  },
  
  disableFacets : function(keepView) {
    _.each(this.facetViews, function(view) {
      if (view != keepView &&
          (view.modes.editing == 'is' ||
           view.modes.selected == 'is')) {
        console.log(['disabling view', view]);
        view.disableEdit();
        view.deselectFacet();
      }
    });
  },

  hideSearch : function() {
    $(document.body).setMode(null, 'search');
  },

  showDocuments : function() {
    var query       = this.value();
    var title       = dc.model.DocumentSet.entitle(query);
    var projectName = SearchQuery.find('project');
    var groupName   = SearchQuery.find('group');

    $(document.body).setMode('active', 'search');
    this.titleBox.html(title);
    dc.app.organizer.highlight(projectName, groupName);
  },

  startSearch : function() {
    dc.ui.spinner.show();
    dc.app.paginator.hide();
    _.defer(dc.app.toolbar.checkFloat);
  },

  cancelSearch : function() {
    this.value('');
  },

  // Webkit knows how to fire a real "search" event.
  searchEvent : function(e) {
    var query = this.value();
    console.log(['real searchEvent', e, query]);
    if (!dc.app.searcher.flags.outstandingSearch) dc.app.searcher.search(query);
    this.focusSearch();
  },
  
  // Shortcut to the searchbox's value.
  value : function(query) {
    if (query == null) return this.getQuery();
    return this.setQuery(query);
  },
  
  getQuery : function() {
    var query = [];
    SearchQuery.each(_.bind(function(facet, i) {
      query.push(this.inputViews[i].value());
      query.push(facet.serialize());
    }, this));
    if (this.inputViews && this.inputViews.length) {
      query.push(this.inputViews[this.inputViews.length-1].value());
    }
    console.log(['getQuery', query, _.compact(query)]);
    
    return _.compact(query).join(' ');
  },

  setQuery : function(query) {
    this.currentQuery = query;
    dc.app.SearchParser.parse(query);
    this.clearInputs();
  },
  
  renderQuery : function() {
     this.setQuery(this.value());
  },
  
  viewPosition : function(view) {
    var position = 0;
    var views = view.type == 'facet' ? this.facetViews : this.inputViews;
    _.each(views, function(inputView, i) {
      if (inputView == view) position = i;
    });
    return position;
  },
    
  addFacet : function(category, initialQuery, inputView) {
    var position = inputView && {at: this.viewPosition(inputView)};
    console.log(['addFacet', category, initialQuery, position]);
    var model = new dc.model.SearchFacet({
      category : category,
      value    : initialQuery || ''
    });
    SearchQuery.add(model, position);
    var facetView = this.renderFacet(model, position);
    facetView.enableEdit();
  },

  // Renders each facet as a searchFacet view.
  renderFacets : function() {
    this.facetViews = [];
    this.inputViews = [];
    
    this.$('.search_inner').empty();
    this.renderSearchInput();
    
    SearchQuery.each(_.bind(function(facet, i) {
      if (facet.get('category') == 'entities') {
        console.log(['entities', facet]);
      } else {
        this.renderFacet(facet, i);
      }
    }, this));
  },
  
  // Render a single facet, using its category and query value.
  renderFacet : function(facet, order) {
    var view = new dc.ui.SearchFacet({
      model : facet,
      order : order
    });
    
    this.facetViews.splice(order, 0, view);
    this.$('.search_inner').children().eq(order*2).after(view.render().el);
    
    view.calculateSize();
    _.defer(_.bind(view.calculateSize, view));
    
    this.renderSearchInput();
    return view;
  },
  
  renderSearchInput : function() {
    var input = new dc.ui.SearchInput();
    this.$('.search_inner').append(input.render().el);
    this.inputViews.push(input);
  },
  
  clearInputs : function() {
    _.each(this.inputViews, function(input) {
      input.clear();
    });
  },
    
  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    var count      = dc.app.paginator.query.total;
    var documents  = dc.inflector.pluralize('Document', count);
    var searchType = SearchQuery.searchType();
    
    if (dc.app.searcher.flags.related) {
      this.titleBox.text(count + ' ' + documents + ' Related to "' + dc.inflector.truncate(dc.app.searcher.relatedDoc.get('title'), 100) + '"');
    } else if (dc.app.searcher.flags.specific) {
      this.titleBox.text(count + ' ' + documents);
    } else if (searchType == 'search') {
      var quote  = SearchQuery.has('project');
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
  
  focusNextFacet : function(currentView, direction, startAtEnd, selectFacet) {
    console.log(['focusNextFacet', currentView, direction]);
    var currentFacetIndex = 0;
    var viewsCount = this.facetViews.length;
    
    _.each(this.facetViews, function(facetView, i) {
      if (currentView == facetView || currentView == i) {
        currentFacetIndex = i;
      }
    });
    
    var next = currentFacetIndex + direction;
    if (next < 0) {
      // Do nothing, at beginning.
      if (selectFacet) {
        this.facetViews[currentFacetIndex].selectFacet();
      } else {
        this.box.focus();
      }
    } else if (next > viewsCount-1) {
      this.box.focus();
    } else {
      this.box.blur();
      if (selectFacet) {
        this.facetViews[next].selectFacet();
      } else {
        this.facetViews[next].enableEdit();
        this.facetViews[next].setCursorAtEnd(direction || startAtEnd);
      }
    }
    this.resizeFacets();
  },
  
  selectAllFacets : function(currentView) {
    _.each(this.facetViews, function(facetView, i) {
      facetView.selectFacet(null, true);
    });
    this.box.focus();
    this.box.selectRange(0, this.box.val().length);
    this.allSelected = true;
  },
  
  disableAllFacets : function(currentView) {
    _.each(this.facetViews, function(facetView, i) {
      facetView.disableEdit();
    });
  },
  
  focusCategory : function(category) {
    _.each(this.facetViews, function(facetView) {
      if (facetView.options.category == category) {
        facetView.enableEdit();
      }
    });
  },
  
  resizeFacets : function() {
    _.each(this.facetViews, function(facetView, i) {
      facetView.resize();
    });
  },

  focusSearch : function(e) {
    console.log(['focusSearch', e]);
    if (!e || $(e.target).is('#search_box_wrapper') || $(e.target).is('.search_inner')) {
      this.inputViews[this.inputViews.length-1].focus();
      this.disableAllFacets();
    }
  },
  
  addFocus : function() {
    Documents.deselectAll();
    this.$('.search').addClass('focus');
  },

  removeFocus : function() {
    this.$('.search').removeClass('focus');
  },
    
  showFacetCategoryMenu : function(e) {
    e.preventDefault();
    e.stopPropagation();
    console.log(['showFacetCategoryMenu', e]);
    if (this.facetCategoryMenu && this.facetCategoryMenu.modes.open == 'is') {
      return this.facetCategoryMenu.close();
    }
    
    var items = [
      {title: 'Account', onClick: _.bind(this.addFacet, this, 'account', '')},
      {title: 'Project', onClick: _.bind(this.addFacet, this, 'project', '')},
      {title: 'Filter', onClick: _.bind(this.addFacet, this, 'filter', '')},
      {title: 'Access', onClick: _.bind(this.addFacet, this, 'access', '')}
    ];
    
    var menu = this.facetCategoryMenu || (this.facetCategoryMenu = new dc.ui.Menu({
      items       : items,
      standalone  : true
    }));
    
    this.$('.search_glyph').after(menu.render().open().content);
    return false;
  }
  
});