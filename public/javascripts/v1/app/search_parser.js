// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  FIRST_PROJECT : /project:\s?([^'"][^'"]\S*|['"].+?['"])/i,

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && project[1];
  }

};