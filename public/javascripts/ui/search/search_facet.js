dc.ui.SearchFacet = Backbone.View.extend({
   
  events : {
  
  },
  
  initialize : function(options) {
      
  },
  
  render : function() {
    var $el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      category : this.options.category,
      query    : this.options.query
    }));
    return this;
  }
   
});