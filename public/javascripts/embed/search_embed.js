
window.dc = window.dc || {};
window.dc.embed = window.dc.embed || {};
  
dc.loadSearchEmbed = function(searchUrl, opts) {
  var query = Inflector.sluggify(opts['q']);
  var defaults = {
    callback : 'dc.loadJSON'
  };
  
  dc.embed[query] = {};
  dc.embed[query].options = $.extend({}, defaults, opts);
  
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
  
  initialize : function() {
    this.embed     = dc.embed[this.options.id];
    this.container = $('#' + this.options['container']);

    this.render();
    this.renderDocuments();
  },
  
  render : function() {
    $(this.el).html(JST['workspace']({}));
    this.container.html(this.el);
  },
  
  renderDocuments : function() {
    var $document_list = this.$('.DC-document-list');
    $document_list.empty();
    
    this.embed.documents.each(_.bind(function(doc) {
      var view = (new dc.EmbedDocumentView({model: doc})).render().el;
      $document_list.append(view);
    }, this));
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
