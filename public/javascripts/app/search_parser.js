// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  ALL_FIELDS        : /\w+:\s?(('.+?'|".+?")|([^'"]{2}\S*))/g,
  
  FIELD             : /(.+?):\s*/,
  
  ONE_ENTITY        : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ALL_ENTITIES      : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/ig,

  ALL_FIELDS        : /\w+:\s?(('.+?'|".+?")|([^'"]{2}\S*))/g,

  FIRST_FILTER      : /filter:\s*(\w+)/i,

  PROJECT_QUERY     : /project(id)?:/,

  WHITESPACE_ONLY   : /^\s*$/,

  extractText : function(query) {
    return dc.inflector.trim(query.replace(this.ALL_FIELDS, ''));
  },

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && (project[2] || project[3] || project[4]);
  },
  
  extractAllFacets : function(query) {
    var facets = [];
    var count = 0;
    
    while (query) {
      var category, value;
      var field = this.extractFirstField(query);
      if (!field) {
        category = 'text';
        value = this.extractSearchText(query);
        query = dc.inflector.trim(query.replace(value, ''));
      } else {
        category = field.match(this.FIELD)[1];
        value    = field.replace(this.FIELD, '').replace(/(^['"]|['"]$)/g, '');
        query    = dc.inflector.trim(query.replace(field, ''));
      }
      // console.log(['extractAllFacets', query, category, value, field]);
      if (category && value) {
          var searchFacet = new dc.model.SearchFacet({
            category : category,
            value    : value
          });
          facets.push(searchFacet);
      }
      if (count++ > 5) break;
    }
    
    return facets;
  },
  
  extractFirstField : function(query) {
    var fields = query.match(this.ALL_FIELDS);
    return fields && fields.length && fields[0];
  },
  
  extractSearchText : function(query) {
    query = query || '';
    var text = dc.inflector.trim(query.replace(this.ALL_FIELDS, ''));
    // console.log(['extractSearchText', query, text]);
    return text;
  },

  extractEntities : function(query) {
    var all = this.ALL_ENTITIES, one = this.ONE_ENTITY;
    var entities = query.match(all) || [];
    return _.sortBy(_.map(entities, function(ent){
      var match = ent.match(one);
      return {type : match[1], value : match[3] || match[4] || match[5]};
    }), function(ent) {
      return ent.value.toLowerCase();
    }).reverse();
  }

};