dc.ui.PublishPreview = dc.ui.Dialog.extend({
  
  callbacks : {
    'input[name=zoom_specific].focus'        : '_selectZoomSpecific',
    'input[name=viewer_size].change'         : '_selectViewerSize',
    'input[name=width].focus'                : '_selectViewerFixed',
    'input[name=height].focus'               : '_selectViewerFixed',
    '.publish_preview_new_window_link.click' : 'previewEmbedNewWindow',
    '.publish_advanced.click'                : '_showAdvancedOptions',
    '.ok.click'                              : 'confirm',
    'input.change'                           : 'update',
    'select.change'                          : 'update',
    'input.keyup'                            : 'update',
    'input.focus'                            : 'update',
    'input.click'                            : 'update'
  },
  
  VIEWER_DEFAULTS : {
    zoom             : 700,
    showSidebar      : true,
    showText         : true,
    showSearch       : true,
    showHeader       : true,
    enableUrlChanges : true
  },
  
  DEFAULT_FULLSCREEN_OPTIONS : {
    container        : '#document-viewer',
    viewer_size      : 'full',
    width            : 600,
    height           : 800,
    zoom             : 700,
    showSidebar      : true,
    showText         : true,
    showHeader       : true,
    enableUrlChanges : true
  },
  
  DEFAULT_FIXED_OPTIONS : {
    container        : '#document-viewer',
    viewer_size      : 'fixed',
    width            : 600,
    height           : 800,
    zoom             : 'auto',
    showSidebar      : false,
    showText         : true,
    showHeader       : true,
    enableUrlChanges : false
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
    if (dc.app.preferences.get('embed_options')) {
      this._loadPreferences();
    }
    this.update();
    this.center();
    _.bindAll(this, '_showAdvancedOptions');
    return this;
  },
  
  displayTitle : function() {
    return 'Embed ' + this.embedDoc.attributes().title;
  },
  
  previewEmbedNewWindow : function(e) {
    e.preventDefault();
    
    var previewUrl = [
      '/documents/',
      this.embedDoc.id,
      '-',
      this.embedDoc.get('slug'),
      '/preview/?options=',
      encodeURIComponent(JSON.stringify(this.embedOptions))
    ].join('');
    
    window.open(previewUrl);
  },
  
  update : function() {
    this._savePreferences();
    this._renderEmbedCode();
    this._setWidthHeightInputs();
    this._enableTextTabOption();
  },
  
  _savePreferences : function() {
    var userOpts = $('form.publish_options', this.el).serializeJSON();
    dc.app.preferences.set({'embed_options': JSON.stringify(userOpts)});
  },
  
  _loadPreferences : function() {
    var userOpts = JSON.parse(dc.app.preferences.get('embed_options')) || {};
    
    this.setOptions(userOpts);
  },
  
  setOptions : function(opts) {
    var $form = $('form', this.el);
    var $formElements = $('input, select', $form);
    
    $formElements.each(function(i) {
      var $this = $(this);
      var inputName = $this.attr('name');
      if (inputName in opts) {
        if ($this.is('input[type=radio]')) {
          if (inputName == 'zoom' && opts[inputName] != 'auto' && $this.val() == 'specific') {
           $this.attr('checked', true);
          } else if ($this.val() == opts[inputName]) {
            $this.attr('checked', true);
          }
        } else {
          $this.val(opts[$this.attr('name')]);
        }
      } else {
        if ($this.is('input[type=checkbox]')) {
          $this.removeAttr('checked');
        } else if ($this.is('input[type=text]')) {
          $this.val('');
        }
      }
    });
  },
  
  _renderEmbedCode : function() {
    var $form = $('form.publish_options', this.el);
    var userOpts = {};
    
    userOpts['viewer_size'] = $('input[name=viewer_size]:checked', $form).val();
    if (userOpts['viewer_size'] == 'fixed') {
      userOpts['width'] = parseInt($('input[name=width]', $form).val(), 10);
      userOpts['height'] = parseInt($('input[name=height]', $form).val(), 10);
    }
    if ($('input[name=zoom]:checked', $form).val() == 'auto') {
      userOpts['zoom'] = 'auto';
    } else {
      userOpts['zoom'] = parseInt($('input[name=zoom_specific]', $form).val(), 10);
    }
    userOpts['showSidebar'] = $('input[name=showSidebar]').attr('checked');
    userOpts['showText'] = $('input[name=showText]').attr('checked');
    userOpts['showHeader'] = $('input[name=showHeader]').attr('checked');
    userOpts['enableUrlChanges'] = $('input[name=enableUrlChanges]').attr('checked');

    var defaultOptions = userOpts['viewer_size'] == 'fixed' ?
                         this.DEFAULT_FIXED_OPTIONS :
                         this.DEFAULT_FULLSCREEN_OPTIONS;
    
    var options = $.extend({}, defaultOptions, userOpts);

    if (options['viewer_size'] == 'full') {
      delete options['width'];
      delete options['height'];
    }
    delete options['viewer_size'];
    delete options['zoom_specific'];
    
    // Remove options that are the same as defaults
    _.each(options, _.bind(function(v, k) {
      if (typeof v == 'boolean' && v == this.VIEWER_DEFAULTS[k]) {
        delete options[k];
      }
    }, this));
    
    options = _.map(options, function(value, key) {
      return key + ": " + (typeof value == 'string' ? "\""+value+"\"" : value);
    });
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({
      doc: this.embedDoc,
      options: options.join(',&#10;    ')
    }));
    
    this.embedOptions = options;
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
  
  _enableTextTabOption : function() {
    var $texttab = $('input[name=showText]', this.el);
    if ($('input[name=showHeader]', this.el).attr('checked')) {
      $texttab.removeClass('disabled').removeAttr('disabled');
    } else {
      $texttab.addClass('disabled').attr('disabled', true);
    }
  },
  
  _selectZoomSpecific : function() {
    $('input#publish_option_zoom_specific', this.el).attr('checked', true);
  },
  
  _selectViewerFixed : function() {
    var $viewerFixed = $('input#publish_option_viewer_size_fixed', this.el);
    if (!$viewerFixed.attr('checked')) {
      $viewerFixed.attr('checked', true);
      this._selectViewerSize();
    }
  },
  
  _selectViewerSize : function() {
    var viewer = $('input[name=viewer_size]:checked').val();

    if (viewer == 'fixed') {
      this.setOptions(this.DEFAULT_FIXED_OPTIONS);
      $('input[name=zoom_specific]', this.el).val(this.DEFAULT_FULLSCREEN_OPTIONS['zoom']);
    } else if (viewer == 'full') {
      this.setOptions(this.DEFAULT_FULLSCREEN_OPTIONS);
      $('input#publish_option_zoom_specific', this.el).attr('checked', true);
      $('input[name=zoom_specific]', this.el).val(this.DEFAULT_FULLSCREEN_OPTIONS['zoom']);
    }
  },
  
  _showAdvancedOptions : function() {
    var $advancedLink = $('.publish_advanced', this.el);
    var $advancedOptions = $('.publish_options_group_advanced', this.el);
    
    if ($advancedLink.hasClass('active')) {
      $advancedLink.removeClass('active');
      $advancedOptions.slideUp(250);
    } else {
      $advancedLink.addClass('active');
      $advancedOptions.slideDown(250);
    }
  }
  
});