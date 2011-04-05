dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  QUOTABLE_CATEGORIES : [
    'project'
  ],
  
  events : {
    'click'                    : 'enableEdit',
    // 'focus input'              : 'enableEdit',
    'keypress input'           : 'maybeDisableEdit',
    'blur input'               : 'disableEdit',
    'change input'             : 'disableEdit',
    'mouseover .cancel_search' : 'showDelete',
    'mouseout .cancel_search'  : 'hideDelete',
    'click .cancel_search'     : 'remove'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'set');
  },
  
  render : function() {
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      category   : this.options.category,
      facetQuery : this.options.facetQuery
    }));
    
    this.setMode('not', 'editing');
    
    this.box = this.$('input');
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    _.defer(_.bind(function() {
      this.box.autoGrowInput();
    }, this));
    
    if (this.options.facetQuery) {
      this.committed = true;
    }
    
    return this;
  },
  
  setupAutocomplete : function() {
    var data = this.autocompleteValues();
    
    this.box.autocomplete(data, {
      width     : 200,
      minChars  : 0,
      autoFill  : true,
      clickFire : true,
      formatItem : function(values, i, n) {
        return values.length == 2 ? values[1] : values[0];
      },
      formatResult : function(value) {
        return value[0];
      }
    }).result(_.bind(function(e, values, data) {
      console.log(['result facet', values, data]);
      e.preventDefault();
      this.set(values[0]);
      return false;
    }, this));
  },
  
  set : function(value) {
    this.options.facetQuery = value;
    this.render();
    dc.app.searchBox.searchEvent();
  },
  
  enableEdit : function(e) {
    console.log(['enableEdit', e, this.options.category]);
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.setupAutocomplete();
      if (this.box.val() == '') {
        this.box.val(this.options.facetQuery).focus().keyup();
      }
      dc.app.searchBox.addFocus();
    }
  },
  
  maybeDisableEdit : function(e) {
    console.log(['disableEdit', e.keyCode]);
    if (e.keyCode == 13 && this.box.val()) { // Enter key
      this.disableEdit(e);
      dc.app.searchBox.searchEvent(e);
    }
    if (dc.app.hotkeys.shift && e.keyCode == 9) { // Tab key
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (e.keyCode == 9) {
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, 1);
    }
  },
  
  disableEdit : function(e) {
    // e.preventDefault();
    console.log(['disableEdit', e]);
    var newFacetQuery = this.box.val();
    this.options.facetQuery = newFacetQuery;
    this.setMode('not', 'editing');
    dc.app.searchBox.removeFocus();
    // this.box.unautocomplete();
    if (this.options.facetQuery) {
      this.committed = true;
    }
    if (!newFacetQuery) {
      this.remove();
    }
  },
  
  remove : function(e) {
    console.log(['remove facet', e]);
    this.$el.remove();
    dc.app.searchBox.removeFacet(this);
    if (this.committed) {
      dc.app.searchBox.searchEvent(e);
    }
  },

  autocompleteValues : function() {
    var category = this.options.category;
    var values = [];
    
    if (category == 'account') {
      values = Accounts.map(function(a) { return [a.get('slug'), a.fullName()]; });
    } else if (category == 'project') {
      values = Projects.pluck('title');
    } else if (category == 'filter') {
      values = ['published', 'annotated', 'public'];
    } else if (category == 'access') {
      values = ['public', 'private', 'organization'];
    }
    
    return values;
  },
  
  serialize : function() {
    var category = this.options.category;
    var query    = dc.inflector.trim(this.options.facetQuery);
    
    if (_.contains(this.QUOTABLE_CATEGORIES, category) && query) query = '"' + query + '"';
    
    if (category != 'text') {
      category = category + ': ';
    } else {
      category = "";
    }
    
    return category + query + ' ';
  },
  
  showDelete : function() {
    this.$el.addClass('search_facet_maybe_delete');
  },
  
  hideDelete : function() {
    this.$el.removeClass('search_facet_maybe_delete');
  }
  
  
   
});