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
  
  PREFIXES : [
    { label: 'project',       category: '' },
    { label: 'text',          category: '' },
    { label: 'title',         category: '' },
    { label: 'description',   category: '' },
    { label: 'source',        category: '' },
    { label: 'account',       category: '' },
    { label: 'document',      category: '' },
    { label: 'filter',        category: '' },
    { label: 'group',         category: '' },
    { label: 'access',        category: '' },
    { label: 'related',       category: '' },
    { label: 'projectid',     category: '' },
    { label: 'city',          category: 'entities' },
    { label: 'country',       category: 'entities' },
    { label: 'term',          category: 'entities' },
    { label: 'state',         category: 'entities' },
    { label: 'person',        category: 'entities' },
    { label: 'place',         category: 'entities' },
    { label: 'organization',  category: 'entities' },
    { label: 'email',         category: 'entities' },
    { label: 'phone',         category: 'entities' }
  ],

  events : {
    'click .search_glyph'       : 'showFacetCategoryMenu',
    'keypress #search_box'      : 'maybeSearch',
    'keydown #search_box'       : 'keydown',
    // 'search #search_box'        : 'searchEvent',
    'focus #search_box'         : 'addFocus',
    'blur #search_box'          : 'removeFocus',
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
    this.box      = this.$('#search_box');
    this.titleBox = this.$('#title_box_inner');
    $(document.body).setMode('no', 'search');
    
    this.setupAutocomplete();
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    this.box.autoGrowInput();
    this.box.bind('updated.autogrow', _.bind(this.moveAutocomplete, this));
        
    return this;
  },

  setupAutocomplete : function() {
    this.box.autocomplete({
      source    : this.PREFIXES,
      minLength : 1,
      delay     : 50,
      autoFocus : true,
      source    : _.bind(function(req, resp) {
        // Autocomplete phrases only from the beginning.
        var re = $.ui.autocomplete.escapeRegex(req.term);
        var matcher = new RegExp('^' + re, 'i');
        resp(_.sortBy($.grep(this.PREFIXES, function(item) {
          return matcher.test(item.label);
        }), function(match) {
          return match.category + '-' + match.label;
        }));
      }, this),
      select    : _.bind(function(e, ui) {
        console.log(['select autocomplete', e, ui]);
        e.preventDefault();
        e.stopPropagation();
        this.addFacet(ui.item.value);
        return false;
      }, this)
    });
    
    this.box.data('autocomplete')._renderMenu = function(ul, items) {
      // Renders the results under the categories they belong to.
      var category = '';
      _.each(items, _.bind(function(item, i) {
        if (item.category && item.category != category) {
          ul.append('<li class="ui-autocomplete-category">' + item.category + '</li>');
          category = item.category;
        }
        this._renderItem(ul, item);
      }, this));
    };
    
    this.box.autocomplete('widget').addClass('interface');
  },
  
  moveAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) {
      autocomplete.menu.element.position({
        my: "left top",
        at: "left bottom",
        of: this.box.data('autocomplete').element,
        collision: "none"
      });
    }
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
  },
  
  // Shortcut to the searchbox's value.
  value : function(query) {
    if (query == null) return this.getQuery();
    return this.setQuery(query);
  },
  
  getQuery : function() {
    var query = SearchQuery.map(function(facet) {
      return facet.serialize();
    }).join(' ');
    console.log(['getQuery', query, this.facetViews]);
    var boxVal = this.box.val();
    if (boxVal) query += ' ' + boxVal;
    
    return query;
  },
  
  setQuery : function(query) {
    // if (this.currentQuery != query) {
      this.currentQuery = query;
      dc.app.SearchParser.parse(query);
      this.box.val('');
    // }
  },
  
  queryWithoutCategory : function(category) {
    var query = SearchQuery.map(function(facet) {
      if (facet.get('category') != category) return facet.serialize();
    }).join(' ');

    query += ' ' + this.box.val();
    
    return query;
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

  // Callback fired on key press in the search box. We search when they hit
  // return.
  maybeSearch : function(e) {
    this.box.trigger('resize.autogrow', e);
    // console.log(['box key', e.keyCode, dc.app.hotkeys.key(e)]);
    if (!dc.app.searcher.flags.outstandingSearch && dc.app.hotkeys.key(e) == 'enter') {
      return this.searchEvent(e);
    }

    if (dc.app.hotkeys.colon(e)) {
      var query = this.box.val();
      if (_.contains(_.pluck(this.PREFIXES, 'label'), query)) {
        e.preventDefault();
        this.addFacet(query);
        return false;
      }
    }
  },
  
  keydown : function(e) {
    dc.app.hotkeys.down(e);
    // console.log(['box keydown', e.keyCode, this.box.getCursorPosition()]);
    this.box.trigger('resize.autogrow', e);
    if (dc.app.hotkeys.left) {
      if (this.box.getCursorPosition() == 0) {
        e.preventDefault();
        this.focusNextFacet(this.facetViews.length-1, 0, -1);
      }
    } else if (dc.app.hotkeys.shift && dc.app.hotkeys.tab) {
      e.preventDefault();
      this.focusNextFacet(this.facetViews.length-1, 0);
    } else if (dc.app.hotkeys.tab) {
      e.preventDefault();
      this.focusNextFacet(null, 0);
    } else if (dc.app.hotkeys.backspace) {
      if (this.box.getCursorPosition() == 0 && !this.box.getSelection().length) {
        e.preventDefault();
        this.focusNextFacet(this.facetViews.length-1, 0, -1, true);
      }
    }
  },

  // Webkit knows how to fire a real "search" event.
  searchEvent : function(e) {
    var query = this.value();
    console.log(['real searchEvent', e, query]);
    if (!dc.app.searcher.flags.outstandingSearch) dc.app.searcher.search(query);
    this.box.focus();
    this.closeAutocomplete();
  },
  
  closeAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.close();
  },
  
  renderQuery : function() {
     this.setQuery(this.value());
  },
    
  addFacet : function(category, initialQuery) {
    console.log(['addFacet', category, initialQuery]);
    this.box.val('');
    var model = new dc.model.SearchFacet({
      category : category,
      value    : initialQuery || ''
    });
    SearchQuery.add(model);
    var view = this.renderFacet(model);
    view.enableEdit();
  },

  // Renders each facet as a searchFacet view.
  renderFacets : function() {
    this.$('.search_facets').empty();
    this.facetViews = [];
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
    
    this.facetViews.push(view);
    this.$('.search_facets').append(view.render().el);
    view.calculateSize();
    _.defer(_.bind(view.calculateSize, view));
    
    return view;
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
  },
  
  focusCategory : function(category) {
    _.each(this.facetViews, function(facetView) {
      if (facetView.options.category == category) {
        facetView.enableEdit();
      }
    });
  },

  blur : function() {
    this.box.blur();
  },

  focusSearch : function(e) {
    console.log(['focusSearch', e]);
    if (!e || $(e.target).is('#search_box_wrapper') || $(e.target).is('.search_inner')) {
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