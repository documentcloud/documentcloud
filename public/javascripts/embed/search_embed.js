
window.dc = window.dc || {};
window.dc.embed = window.dc.embed || {};
  
dc.loadSearchEmbed = function(searchUrl, opts) {
  var query = Inflector.sluggify(opts['q']);
  var defaults = {
    callback : 'dc.loadJSON'
  };
  
  dc.embed[query] = {};
  dc.embed[query].options = $.extend({}, defaults, opts);
  dc.embed[query].searchUrl = searchUrl;
  
  $.getScript(searchUrl + '?' + $.param(dc.embed[query].options));
};

dc.loadJSON = function(json) {
  var query = Inflector.sluggify(json.q);
  dc.embed[query].options['id'] = query;
  dc.embed[query].documents = new dc.EmbedDocumentSet(json.documents, dc.embed[query].options);
  dc.embed[query].workspace = new dc.EmbedWorkspaceView(dc.embed[query].options);
};

dc.EmbedDocument = Backbone.Model.extend({
  
  
  
});

dc.EmbedDocumentSet = Backbone.Collection.extend({

  model : dc.EmbedDocument

});

dc.EmbedWorkspaceView = Backbone.View.extend({
  
  events : {
    'click    .DC-cancel-search' : 'cancelSearch',
    'keypress #DC-search-box'    : 'performSearch'
  },
  
  initialize : function() {
    this.embed     = dc.embed[this.options.id];
    this.container = $('#' + this.options['container']);

    this.render();
  },
  
  render : function() {
    $(this.el).html(JST['workspace']({}));
    this.container.html(this.el);
    
    this.search    = this.$('#DC-search-box');
    
    this.search.placeholder({className: 'DC-placeholder'});
    this.renderDocuments();
  },
  
  renderDocuments : function() {
    var $document_list = this.$('.DC-document-list');
    $document_list.empty();
    
    this.embed.documents.each(_.bind(function(doc) {
      var view = (new dc.EmbedDocumentView({model: doc})).render().el;
      $document_list.append(view);
    }, this));
  },
  
  cancelSearch : function() {
    this.search.val('').blur();
  },
  
  performSearch : function(e) {
    if (e.keyCode != 13) return; // Search on `enter` only
    
    // $.getScript(this.embed.searchUrl)
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
