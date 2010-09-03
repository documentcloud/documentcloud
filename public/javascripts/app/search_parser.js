// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  FIRST_PROJECT   : /project:\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_DOC     :  /document:\s?(\d+-\S+)/i,

  FIRST_ACCOUNT   : /account:\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_PUBLISHED : /published:\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_GROUP     : /group:\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_RELATED   : /related:\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ONE_ENTITY      : /(city|country|term|state|person|place|organization):\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ALL_ENTITIES    : /(city|country|term|state|person|place|organization):\s?(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/ig,

  WHITESPACE_ONLY : /^\s*$/,

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && (project[2] || project[3] || project[4]);
  },

  extractAccount : function(query) {
    var account = query.match(this.FIRST_ACCOUNT);
    return account && (account[2] || account[3] || account[4]);
  },

  extractPublished : function(query) {
    var account = query.match(this.FIRST_PUBLISHED);
    return account && (account[2] || account[3] || account[4]);
  },

  extractGroup : function(query) {
    var group = query.match(this.FIRST_GROUP);
    return group && (group[2] || group[3] || group[4]);
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
  },

  extractRelatedDocId : function(query) {
    var relatedDocument = query.match(this.FIRST_RELATED);
    return relatedDocument && (relatedDocument[2] || relatedDocument[3] || relatedDocument[4]);
  },

  extractSpecificDocId : function(query) {
    var id = query.match(this.FIRST_DOC);
    return id && id[1];
  },

  searchType : function(query) {
    if (query.replace(this.FIRST_RELATED, '').match(this.WHITESPACE_ONLY)) return 'related';
    if (query.replace(this.FIRST_PROJECT, '').match(this.WHITESPACE_ONLY)) return 'project';
    if (query.replace(this.FIRST_ACCOUNT, '').match(this.WHITESPACE_ONLY)) return 'account';
    if (query.replace(this.FIRST_PUBLISHED, '').match(this.WHITESPACE_ONLY)) return 'published';
    return 'search';
  }

};