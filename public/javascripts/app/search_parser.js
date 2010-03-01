// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  FIRST_PROJECT :  /project:\s?(([^'"][^'"]\S*)|['"](.+?)['"])/i,

  WHITESPACE_ONLY: /^\s*$/,

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && (project[2] || project[3]);
  },

  projectOnly : function(query) {
    return !!query.replace(this.FIRST_PROJECT, '').match(this.WHITESPACE_ONLY);
  }

};