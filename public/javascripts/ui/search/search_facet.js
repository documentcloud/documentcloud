dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  QUOTABLE_CATEGORIES : [
    'project'
  ],
  
  events : {
    'click'         : 'enableEdit',
    'focus'         : 'enableEdit',
    'keydown input' : 'maybeDisableEdit',
    'blur input'    : 'disableEdit',
    'change input'  : 'disableEdit'
  },
  
  initialize : function(options) {
      this.setMode('not', 'editing');
      _.bindAll(this, 'autocompleteValueCheck', 'autocompleteValueSuccess');
  },
  
  render : function() {
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      category   : this.options.category,
      facetQuery : this.options.facetQuery
    }));
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    _.defer(function() {
      $('input', $el).autoGrowInput();
    });

    this.autocomplete = new dc.ui.Autocomplete({
      input           : this.$('input'), 
      checkCallback   : this.autocompleteValueCheck, 
      successCallback : this.autocompleteValueSuccess
    });
    return this;
  },
  
  autocompleteValueCheck : function() {
    
  },
  
  autocompleteValueSuccess : function() {
    
  },
  
  serialize : function() {
    var category = this.options.category;
    var query    = Inflector.trim(this.options.facetQuery);
    
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
      this.$('input').val(this.options.facetQuery).focus();
      
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
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (e.keyCode == 9) {
      e.preventDefault();
      dc.app.searchBox.focusNextFacet(this, 1);
    }
  },
  
  disableEdit : function() {
    var newFacetQuery = this.$('input').val();
    if (newFacetQuery != this.options.facetQuery) {
      this.options.facetQuery = newFacetQuery;
    }
    this.setMode('not', 'editing');
    this.render();
    dc.app.searchBox.removeFocus();
  }
   
});