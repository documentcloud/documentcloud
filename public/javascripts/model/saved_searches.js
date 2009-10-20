// Saved Search Model

dc.model.SavedSearch = dc.Model.extend({
  
});


// Saved Search Set

dc.model.SavedSearchSet = dc.model.RESTfulSet.extend({
  
  resource : 'saved_searches'
  
});

window.SavedSearches = new dc.model.SavedSearchSet();
