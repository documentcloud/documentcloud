// A parallel partial JS implementation of lib/dc/search/parser.rb
// Used to extract keywords from the free text search.
dc.app.SearchParser = {

  BARE_FIELD        : /\w+:\s?[^'"]{2}\S*/g,
  
  QUOTED_FIELD      : /(\w+:\s?("(.+?)"|'(.+?)'))/g,
  
  ALL_FIELDS        : /\w+:\s?(('.+?'|".+?")|([^'"]{2}\S*))/g,
  
  FIELD             : /(.+?):\s*/,
  
  ALL_PROJECTS      : /project:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/ig,

  ALL_PROJECT_IDS   : /projectid:\s*(\d+-\S+)/ig,

  FIRST_DOC         : /document:\s*(\d+-\S+)/i,

  FIRST_ACCOUNT     : /account:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_GROUP       : /group:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  FIRST_RELATED     : /related:\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ONE_ENTITY        : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/i,

  ALL_ENTITIES      : /(city|country|term|state|person|place|organization|email|phone):\s*(([^'"][^'"]\S*)|'(.+?)'|"(.+?)")/ig,

  FIRST_FILTER      : /filter:\s*(\w+)/i,
  
  FIRST_ACCESS      : /access:\s*(\w+)/i,

  PROJECT_QUERY     : /project(id)?:/,

  WHITESPACE_ONLY   : /^\s*$/,

  extract : function(query, field) {
    var fields = this.extractAllFields(query);
    
    return fields[field] || [];
  },
  
  query : function(query) {
    var fields = this.extractAllFields(query);
    var query = new dc.app.SearchQuery(query, fields);
    
    return query;
  },
  
  extractAllFields : function(query) {
    var quotedFields = this.extractQuotedFields(query);
    var bareFields   = this.extractBareFields(query);
    var searchText   = this.extractSearchText(query);
    
    bareFields = _.map(bareFields, _.bind(function(field) { return field.split(/\s*:\s*/); }, this));
    quotedFields = _.map(quotedFields, _.bind(function(field) {
      var match = field.match(this.FIELD);
      var type  = match[1];
      var value = field.replace(match[0], '').replace(/(^['"]|['"]$)/g, '');
      return [type, value];
    }, this));
    var rawFields = bareFields.concat(quotedFields);
    
    var fields = {
      text : searchText && [searchText] || []
    };
    _.each(rawFields, _.bind(function(field) {
      var type  = field[0];
      var value = field[1];
      if (!fields[type]) fields[type] = [];
      fields[type].push(value);
    }, this));
    
    return fields;
  },
  
  extractQuotedFields : function(query) {
    var fields = query.match(this.QUOTED_FIELD);
    return fields;
  },
  
  extractBareFields : function(query) {
    var fields = query.replace(this.QUOTED_FIELD, '').match(this.BARE_FIELD);
    return fields;
  },
  
  extractSearchText : function(query) {
    var text = dc.inflector.trim(query.replace(this.ALL_FIELDS, ''));
    return text;
  },
  
  extractProject : function(query) {
    var project = query.match(this.ALL_PROJECTS);
    return project && (project[2] || project[3] || project[4]);
  },
  
  extractAccount : function(query) {
    var account = query.match(this.FIRST_ACCOUNT);
    return account && (account[2] || account[3] || account[4]);
  },
  
  extractGroup : function(query) {
    var group = query.match(this.FIRST_GROUP);
    return group && (group[2] || group[3] || group[4]);
  },

  extractFilter : function(query) {
    var match = query.match(this.FIRST_FILTER);
    return match && (match[1].toLowerCase());
  },

  extractAccess : function(query) {
    var match = query.match(this.FIRST_ACCESS);
    return match && (match[1].toLowerCase());
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
    if (query.match(this.WHITESPACE_ONLY))                                    return 'all';
    if (query.replace(this.FIRST_RELATED, '').match(this.WHITESPACE_ONLY))    return 'related';
    if (query.replace(this.FIRST_PROJECT, '').match(this.WHITESPACE_ONLY))    return 'project';
    if (query.replace(this.FIRST_PROJECT_ID, '').match(this.WHITESPACE_ONLY)) return 'project';
    if (query.replace(this.FIRST_GROUP, '').match(this.WHITESPACE_ONLY))      return 'group';
    var withoutAccount = query.replace(this.FIRST_ACCOUNT, '');
    if (withoutAccount.match(this.WHITESPACE_ONLY))                           return 'account';
    var filter = this.extractFilter(query);
    var filterOnly = withoutAccount.replace(this.FIRST_FILTER, '').match(this.WHITESPACE_ONLY);
    if (filter && filterOnly && (filter == 'annotated' || filter == 'published' || filter == 'popular')) return filter;
    return 'search';
  }

};