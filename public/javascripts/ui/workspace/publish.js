dc.ui.Publish = dc.View.extend({
  
  callbacks : {
    'input.change' : '_rerenderDocumentLivePreview'
  },
  
  render : function() {
    this.el = $('#publish_container')[0];
    dc.history.register(/^#publish$/,    _.bind(this.openPublishTab, this));
    dc.history.register(/^#publish\//,     _.bind(this.openDocumentInHash, this));
    dc.app.navigation.bind('tab:publish',  _.bind(this.openPublishTab, this));
    _.bindAll(this, '_rerenderDocumentLivePreview');
    $(this.el).html(JST['workspace/publish_live_preview']({}));
    this.setCallbacks();
    return this;
  },
  
  openPublishTab : function() {
    dc.app.navigation.open('publish');
    dc.history.save('publish');
  },
  
  openDocumentInHash : function(hash) {
    var docId = parseInt(dc.app.SearchParser.extractSpecificDocId('docid: ' + hash), 10);
    dc.app.searcher.searchByHash('docid: ' + docId, _.bind(function() {
      var doc = Documents.get(docId);
      this.renderDocumentLivePreview(doc);
    }, this));
  },
  
  renderDocumentLivePreview : function(doc) {
    dc.app.navigation.open('publish');
    dc.history.save('publish/' + doc.id + '-' + doc.attributes().slug);
    this.embedDoc = doc;
    this._renderDocumentHeader();
    this._renderEmbedCode();
  },
  
  _rerenderDocumentLivePreview : function() {
    var docUrl = this.embedDoc.attributes()['document_viewer_js'] + 'on';
    var options = $('form.publish_options', this.el).serializeJSON();
    options = _.each(options, function(v, k) {
      if (v == 'on') options[k] = true;
      if (k == 'zoom' && v == 'specific') options['zoom'] = options['zoom_specific'];
    });
    delete options['zoom_specific'];
    console.log([options]);
    $('iframe#documentViewerPreview')[0].contentWindow.DV.load(docUrl, options);
  },
  
  _renderDocumentHeader : function(doc) {
    Documents.deselectAll();
    var view = new dc.ui.Document({model : this.embedDoc});
    $('.publish_document', this.el).html(view.render().el);
  },
  
  _renderEmbedCode : function(doc) {
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({doc: this.embedDoc}));
  }
  
});