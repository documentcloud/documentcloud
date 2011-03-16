// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  FIRST_PROJECT     : /project:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_DOC         : /document:\s*(\d+-\S+)/i,

  FIRST_ACCOUNT     : /account:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_GROUP       : /group:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_RELATED     : /related:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ONE_ENTITY        : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ALL_ENTITIES      : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/ig,

  FIRST_FILTER      : /filter:\s*(\w+)/i,

  WHITESPACE_ONLY   : /^\s*$/,

  extractProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return project && (project[2] || project[3] || project[4]);
  },
  
  removeProject : function(query) {
    var project = query.match(this.FIRST_PROJECT);
    return query.replace(project && project[0], '');
  },

  extractAccount : function(query) {
    var account = query.match(this.FIRST_ACCOUNT);
    return account && (account[2] || account[3] || account[4]);
  },
  
  removeAccount : function(query) {
    var account = query.match(this.FIRST_ACCOUNT);
    return query.replace(account && account[0], '');
  },

  extractGroup : function(query) {
    var group = query.match(this.FIRST_GROUP);
    return group && (group[2] || group[3] || group[4]);
  },

  removeGroup : function(query) {
    var group = query.match(this.FIRST_GROUP);
    return query.replace(group && group[0], '');
  },

  extractFilter : function(query) {
    var match = query.match(this.FIRST_FILTER);
    return match && (match[1].toLowerCase());
  },

  removeFilter : function(query) {
    var filter = query.match(this.FIRST_FILTER);
    return query.replace(filter && filter[0], '');
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
    if (query.match(this.WHITESPACE_ONLY))                                  return 'all';
    if (query.replace(this.FIRST_RELATED, '').match(this.WHITESPACE_ONLY))  return 'related';
    if (query.replace(this.FIRST_PROJECT, '').match(this.WHITESPACE_ONLY))  return 'project';
    if (query.replace(this.FIRST_GROUP, '').match(this.WHITESPACE_ONLY))    return 'group';
    var withoutAccount = query.replace(this.FIRST_ACCOUNT, '');
    if (withoutAccount.match(this.WHITESPACE_ONLY))                         return 'account';
    var filter = this.extractFilter(query);
    var filterOnly = withoutAccount.replace(this.FIRST_FILTER, '').match(this.WHITESPACE_ONLY);
    if (filter && filterOnly && (filter == 'annotated' || filter == 'published' || filter == 'popular')) return filter;
    return 'search';
  }

};