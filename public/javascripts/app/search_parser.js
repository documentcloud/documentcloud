// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  FIRST_PROJECT :  /project:\s?(([^'"][^'"]\S*)|['"](.+?)['"])/i,

  FIRST_ACCOUNT :  /documents:\s?(([^'"][^'"]\S*)|['"](.+?)['"])/i,

  WHITESPACE_ONLY: /^\s*$/,

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && (project[2] || project[3]);
  },

  extractAccount : function(query) {
    var account = query.match(this.FIRST_ACCOUNT);
    return account && (account[2] || account[3]);
  },

  searchType : function(query) {
    if (query.replace(this.FIRST_PROJECT, '').match(this.WHITESPACE_ONLY)) return 'project';
    if (query.replace(this.FIRST_ACCOUNT, '').match(this.WHITESPACE_ONLY)) return 'account';
    return 'search';
  }

};