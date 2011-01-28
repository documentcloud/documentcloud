
window.dc = window.dc || {};
window.dc.embed = window.dc.embed || {};
  
dc.loadSearchEmbed = function(searchUrl, opts) {
  var query = Inflector.sluggify(opts['q']);
  
  dc.embed[query] = {};
  dc.embed[query].options = opts = _.extend({}, {
    searchUrl     : searchUrl,
    originalQuery : opts['q'],
    per_page      : 12,
    order         : 'score'
  }, opts);
  
  var apiOptions = {
    q        : opts['q'],
    callback : 'dc.loadJSON',
    per_page : opts['per_page'],
    order    : opts['order']
  };
  $.getScript(searchUrl + '?' + $.param(apiOptions));
};

dc.loadJSON = function(json) {
  var query = Inflector.sluggify(json.q);
  dc.embed[query].options['id'] = query;
  dc.embed[query].page = {
    total    : json.total,
    per_page : json.per_page,
    page     : json.page
  };
  dc.embed[query].documents = new dc.EmbedDocumentSet(json.documents, dc.embed[query].options);
  dc.embed[query].workspace = new dc.EmbedWorkspaceView(dc.embed[query].options);
};

dc.EmbedController = function(query, opts) {
  var options = {
    q: opts.originalQuery + ' ' + query,
    original_query: opts.originalQuery,
    callback: 'dc.EmbedControllerCallback'
  };
  $.getScript(opts.searchUrl + '?' + $.param(options));
};

dc.EmbedControllerCallback = function(json) {
  var originalQuery = Inflector.sluggify(json.original_query);
  dc.embed[originalQuery].page = {
    total    : json.total,
    per_page : json.per_page,
    page     : json.page
  };
  dc.embed[originalQuery].documents.refresh(json.documents);
};


dc.EmbedDocument = Backbone.Model.extend({

  url : function() {
    return this.get('resources')['published_url'] || this.get('canonical_url');
  }
  
});

dc.EmbedDocumentSet = Backbone.Collection.extend({

  model : dc.EmbedDocument,
  
  initialize : function(models) {
    this.originalModels = models;
  }

});

dc.EmbedWorkspaceView = Backbone.View.extend({
  
  className : 'DC-search-embed',
  
  events : {
    'click    .DC-cancel-search' : 'cancelSearch',
    'keypress .DC-search-box'    : 'maybePerformSearch'
  },
  
  initialize : function() {
    this.embed     = dc.embed[this.options.id];
    this.container = $('#' + this.options['container']);
    this.embed.documents.bind('refresh', _.bind(this.renderDocuments, this));
    this.render();
  },
  
  render : function() {
    $(this.el).html(JST['workspace']({}));
    this.container.html(this.el);
    
    this.search = this.$('.DC-search-box');
    
    this.search.placeholder({className: 'DC-placeholder DC-interface'});
    this.renderDocuments();
  },
  
  renderDocuments : function() {
    var page = this.embed.page;
    var $document_list = this.$('.DC-document-list');
    $document_list.empty();
    
    if (!this.embed.documents.length) {
      $document_list.append(JST['no_results']({}));
    } else {
      this.embed.documents.each(_.bind(function(doc) {
        var view = (new dc.EmbedDocumentView({model: doc})).render().el;
        $document_list.append(view);
      }, this));
    }

    this.$('.DC-paginator').html(JST['paginator']({
      total      : page.total,
      per_page   : page.per_page,
      page       : page.page,
      page_count : Math.ceil(page.total / page.per_page),
      from       : (page.page-1) * page.per_page,
      to         : Math.min(page.page * page.per_page, page.total)
    }));
  },
  
  cancelSearch : function(e) {
    e.preventDefault();
    this.search.val('').blur();
    this.performSearch();
  },
  
  maybePerformSearch : function(e) {
    if (e.keyCode != 13) return; // Search on `enter` only
    this.performSearch();
  },
  
  performSearch : function() {
    var query = this.$('.DC-search-box').val();
    
    if (query == '') {
      // Returning to original query, just use the original response.
      this.embed.documents.refresh(this.embed.documents.originalModels);
    } else {
      dc.EmbedController(query, this.embed.options);
    }
  }
  
});

dc.EmbedDocumentView = Backbone.View.extend({
  
  events : {
    'click' : 'open'
  },
  
  initialize : function() {
    this.render();
  },
  
  render : function() {
    $(this.el).html(JST['document']({doc: this.model}));
    return this;
  },
  
  open : function(e) {
    e.preventDefault();

    window.open(this.model.get('resources')['published_url'] || this.model.get('canonical_url'));

    return false;
  }
  
});
