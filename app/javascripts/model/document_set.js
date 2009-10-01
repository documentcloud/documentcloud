// TBI.
dc.model.DocumentSet = dc.model.RESTfulSet.extend({
  
  resource : 'documents'
  
});

window.Documents = new dc.model.DocumentSet();
