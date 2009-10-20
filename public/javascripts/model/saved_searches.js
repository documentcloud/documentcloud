// Saved Search Model

dc.model.SavedSearch = dc.Model.extend({
  
});


// Saved Search Set

dc.model.SavedSearchSet = dc.model.RESTfulSet.extend({
  
  resource : 'saved_searches',
  
  find : function(query) {
    return _.detect(this.models(), function(m){ return m.get('query') == query; });
  }
  
});

window.SavedSearches = new dc.model.SavedSearchSet();
