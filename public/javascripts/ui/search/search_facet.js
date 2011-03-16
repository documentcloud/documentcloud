dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
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
  
  enableEdit : function() {
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.$('input').val(this.options.facetQuery).focus();
    }
  },
  
  maybeDisableEdit : function(e) {
    if (e.keyCode == 13) {
      this.disableEdit();
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