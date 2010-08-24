dc.ui.PublishPreview = dc.ui.Dialog.extend({
  
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
  
  constructor : function(doc) {
    console.log(['PublishPreview constructor', doc]);
    this.embedDoc = doc;
    this.base({
      mode        : 'custom',
      title       : this.displayTitle(),
      information : ''
    });
    this.render();
    dc.ui.spinner.show();
  },
  
  render : function() {
    this.el = $('#publish_preview_container')[0];
    _.bindAll(this, '_rerenderDocumentLivePreview', '_loadIFramePreview');
    $(this.el).html(JST['workspace/publish_preview']({}));
    dc.history.save('publish/' + this.embedDoc.id + '-' + this.embedDoc.attributes().slug);
    this._renderDocumentHeader();
    this._renderEmbedCode();
    _.defer(this._loadIFramePreview);
    this.base();
    dc.ui.spinner.hide();
    return this;
  },
  
  displayTitle : function() {
    return 'Embed ' + this.embedDoc.attributes().title;
  },
  
  _loadIFramePreview : function() {
    var $iframe = $('iframe#documentViewerPreview');
    
    $iframe.load(_.bind(function() {
      this._rerenderDocumentLivePreview();
    }, this));
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