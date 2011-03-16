dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  QUOTABLE_CATEGORIES : [
    'project'
  ],
  
  events : {
    'click'         : 'enableEdit',
    'keydown input' : 'maybeDisableEdit',
    'blur input'    : 'disableEdit',
    'change input'  : 'disableEdit'
  },
  
  initialize : function(options) {
      this.setMode('not', 'editing');
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
    return this;
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
    
    console.log(['serialize', category, query]);
    return category + query + ' ';
  },
  
  enableEdit : function() {
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.$('input').val(this.options.facetQuery).focus();
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
  }
   
});