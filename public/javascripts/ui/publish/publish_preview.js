dc.ui.PublishPreview = dc.View.extend({
  
  callbacks : {
    'input.change' : '_rerenderDocumentLivePreview'
  },
  
  DEFAULT_VIEWER_OPTIONS : {
    container: '#DV-container',
    zoom: 'auto',
    showSidebar: false,
    showText: true,
    showSearch: true,
    showHeader: true,
    enableUrlChanges: false
  },
  
  render : function(doc) {
    this.embedDoc = doc;
    this.el = $('#publish_preview_container')[0];
    _.bindAll(this, '_rerenderDocumentLivePreview');
    $(this.el).html(JST['workspace/publish_preview']({}));
    dc.history.save('publish/' + doc.id + '-' + doc.attributes().slug);
    this._renderDocumentHeader();
    this._renderEmbedCode();
    this.setCallbacks();
    return this;
  },
  
  _rerenderDocumentLivePreview : function() {
    dc.ui.spinner.show();

    var docUrl = this.embedDoc.attributes()['document_viewer_js'] + 'on';
    var userOpts = $('form.publish_options', this.el).serializeJSON();
    _.each(this.DEFAULT_VIEWER_OPTIONS, function(v, k) {
      if (!(k in userOpts)) userOpts[k] = false;
      else if (userOpts[k] == 'on') userOpts[k] = true;
      if (k == 'zoom' && userOpts[k] == 'specific') {
        var zoom = parseInt(userOpts['zoom_specific'], 10);
        if (zoom >= 100) {
          userOpts['zoom'] = zoom;
        } else {
          userOpts['zoom'] = 'auto';
        }
      };
    });
    delete userOpts['zoom_specific'];
    var options = $.extend({}, this.DEFAULT_VIEWER_OPTIONS, userOpts);
    console.log([options, userOpts, this.DEFAULT_VIEWER_OPTIONS]);
    
    $('iframe#documentViewerPreview')[0].contentWindow.DV.load(docUrl, options);
    dc.ui.spinner.hide();
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