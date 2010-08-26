dc.ui.PublishPreview = dc.ui.Dialog.extend({
  
  callbacks : {
    'input.change'  : '_renderEmbedCode',
    'select.change' : '_renderEmbedCode',
    'input.keyup'   : '_renderEmbedCode',
    'input.focus'   : '_renderEmbedCode',
    'input.click'   : '_renderEmbedCode',
    'input[name=zoom_specific].focus' : '_selectZoomSpecific',
    'publish_preview_new_window_link.click' : 'previewEmbedNewWindow'
  },
  
  DEFAULT_VIEWER_OPTIONS : {
    container: '#document-viewer',
    viewer_size: 'full',
    width: 600,
    height: 800,
    zoom: 'auto',
    showSidebar: false,
    showText: true,
    showHeader: true,
    enableUrlChanges: false
  },
  
  constructor : function(doc) {
    this.embedDoc = doc;
    this.base({
      mode        : 'custom',
      title       : this.displayTitle(),
      information : ''
    });
    this.setMode('embed', 'dialog');
    this.render();
    dc.ui.spinner.show();
  },
  
  render : function() {
    this.base({
      width: '90%'
    });
    _.bindAll(this, '_renderEmbedCode', 
                    '_selectZoomSpecific', 
                    '_setWidthHeightInputs', 
                    'previewEmbedNewWindow');
    $('.custom', this.el).html(JST['workspace/publish_preview']({}));
    this._renderEmbedCode();
    this._setWidthHeightInputs();
    dc.ui.spinner.hide();
    this.center();
    return this;
  },
  
  displayTitle : function() {
    return 'Embed ' + this.embedDoc.attributes().title;
  },
  
  previewEmbedNewWindow : function(e) {
    e.preventDefault();
    console.log(['params', $.param(this.embedOptions)]);
  },
  
  _renderEmbedCode : function(doc) {
    dc.ui.spinner.show();
    
    this._setWidthHeightInputs();
    
    var userOpts = $('form.publish_options', this.el).serializeJSON();
    _.each(this.DEFAULT_VIEWER_OPTIONS, _.bind(function(v, k) {
      if (!(k in userOpts)) userOpts[k] = false;
      else if (userOpts[k] == 'on') userOpts[k] = true;

      // Zoom override
      if (k == 'zoom' && userOpts[k] == 'specific') {
        var zoom = parseInt(userOpts['zoom_specific'], 10);
        if (zoom >= 100) {
          userOpts['zoom'] = zoom;
        } else {
          userOpts['zoom'] = 'auto';
        }
      }
      
      // Viewer size override
      if (k == 'viewer_size' && userOpts[k] == 'fixed') {
        userOpts['width'] = parseInt(userOpts['width'], 10);
        userOpts['height'] = parseInt(userOpts['height'], 10);
      }
    }, this));
    var options = $.extend({}, this.DEFAULT_VIEWER_OPTIONS, userOpts);

    if (options['viewer_size'] == 'full') {
      delete options['width'];
      delete options['height'];
    }
    delete options['viewer_size'];
    delete options['zoom_specific'];
    
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({
      doc: this.embedDoc,
      options: options
    }));
    
    this.embedOptions = options;
    
    dc.ui.spinner.hide();
  },
  
  _setWidthHeightInputs : function() {
    var $view = $('select[name=viewer_size]', this.el);
    var $dimensions = $('input[name=width],input[name=height]', this.el);

    if ($view.val() == 'full') {
      $dimensions.addClass('disabled').attr('disabled', true);
    } else {
      $dimensions.removeClass('disabled').removeAttr('disabled');
    }
  },
  
  _selectZoomSpecific : function() {
    $('input#publish_option_zoom_specific', this.el).attr('checked', true);
  }
  
});