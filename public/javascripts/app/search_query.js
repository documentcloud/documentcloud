dc.app.SearchQuery = function(query, facets) {
  this.query  = query;
  this.facets = facets;
};

dc.app.SearchQuery.prototype = {
  
  getFacets : function() {
    return this.facets;
  },
  
  has : function(facet) {
    return this.facets[facet] && this.facets[facet].length;
  },
  
  get : function(facet, defaultValue, index) {
    if (!index) index = 0;
    return (this.facets[facet] && this.facets[facet].length && this.facets[facet][index]) || defaultValue;
  },
  
  all : function(facet) {
    return (this.facets[facet] && this.facets[facet].length && this.facets[facet]) || [];
  },
  
  searchType : function() {
    var single   = false;
    var multiple = false;
    
    _.each(this.facets, function(values, facet) {
      if (values.length) {
        if (!single && !multiple) {
          single = facet;
        } else {
          multiple = true;
          single = false;
        }
      }
    });
    
    if (single == 'filter') {
      return this.facets['filter'][0];
    } else if (single) {
      return single;
    } else if (!single && !multiple) {
      return 'all';
    }
    
    return 'search';
  }
  
};