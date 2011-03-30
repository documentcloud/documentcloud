dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  QUOTABLE_CATEGORIES : [
    'project'
  ],
  
  events : {
    'click'                    : 'enableEdit',
    'focus input'              : 'enableEdit',
    'keydown input'            : 'maybeDisableEdit',
    'blur input'               : 'disableEdit',
    'change input'             : 'disableEdit',
    'mouseover .cancel_search' : 'showDelete',
    'mouseout .cancel_search'  : 'hideDelete',
    'click .cancel_search'     : 'remove'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'onSelect');
  },
  
  render : function() {
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      category   : this.options.category,
      facetQuery : this.options.facetQuery
    }));
    $el.setMode('not', 'editing');
    
    this.box = this.$('input');
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    _.defer(_.bind(function() {
      this.box.autoGrowInput();
    }, this));
    
    return this;
  },
  
  remove : function(e) {
    this.$el.remove();
    dc.app.searchBox.removeFacet(this);
    dc.app.searchBox.searchEvent(e);
  },
  
  setupAutocomplete : function() {
    var data = this.autocompleteValues();
    
    this.box.autocomplete(data, {
      width     : 200,
      minChars  : 0,
      autoFill  : true,
      formatItem : function(values, i, n) {
        return values.length == 2 ? values[1] : values[0];
      },
      formatResult : function(value) {
        return value[0];
      }
    });
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
    }
    
    return values;
  },
  
  onSelect : function(value, data) {
    this.box.val(data || value);
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
  
  enableEdit : function() {
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
    if (e.keyCode == 13) { // Enter key
      this.disableEdit();
      dc.app.searchBox.searchEvent(e);
    }
    if (dc.app.hotkeys.shift && e.keyCode == 9) { // Tab key
      e.preventDefault();
      this.disableEdit();
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (e.keyCode == 9) {
      e.preventDefault();
      this.disableEdit();
      dc.app.searchBox.focusNextFacet(this, 1);
    }
  },
  
  disableEdit : function() {
    var newFacetQuery = this.box.val();
    this.options.facetQuery = newFacetQuery;
    this.setMode('not', 'editing');
    this.render();
    dc.app.searchBox.removeFocus();
    this.box.unautocomplete();
  },
  
  showDelete : function() {
    this.$el.addClass('search_facet_maybe_delete');
  },
  
  hideDelete : function() {
    this.$el.removeClass('search_facet_maybe_delete');
  }
  
  
   
});