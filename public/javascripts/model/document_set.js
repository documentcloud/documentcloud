dc.model.DocumentSet = dc.model.RESTfulSet.extend({
  
  resource : 'documents'
  // _results : null,
  // _query   : null,
  
  // constructor : function() {
  //   this.base();
  //   this.resetResults(null);
  // },
  
  // resetResults : function(query) {
  //   this._query = query;
  //   this._results = {};
  //   return false;
  // },
  // 
  // checkCache : function(query, page) {
  //   if (query != this._query) return this.resetResults(query);
  //   return !!this._results[page];
  // },
  
  // refresh : function(documents) {
  //   this.base(documents);
  //   this._results[dc.app.paginator.page] = this.values();
  // }
  
});

window.Documents = new dc.model.DocumentSet();
