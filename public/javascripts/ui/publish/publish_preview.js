dc.ui.PublishPreview = dc.ui.Dialog.extend({

  callbacks : {
    'input[name=viewer_size].change'      : '_selectViewerSize',
    '.preview.click'                      : 'preview',
    'input.change'                        : 'update',
    'select.change'                       : 'update',
    'input.keyup'                         : 'update',
    'input.focus'                         : 'update',
    'input.click'                         : 'update',
    '.next.click'                         : 'nextStep',
    '.previous.click'                     : 'previousStep',
    '.close.click'                        : 'close',
    '.snippet.click'                      : 'selectSnippet'
  },

  totalSteps  : 3,

  STEPS : [
    'Step One: Prepare Document for Publication',
    'Step Two: Configure the Document Viewer',
    'Step Three: Cut and Paste the Embed Code'
  ],

  constructor : function(doc) {
    this.embedDoc = doc;
    this.currentStep = 1;
    this.base({mode : 'custom', title : this.STEPS[0]});
    this.setMode('embed', 'dialog');
    this.render();
  },

  render : function() {
    this.base();
    $('.custom', this.el).html(JST['workspace/publish_preview']({doc: this.embedDoc}));
    if (dc.app.preferences.get('embed_options')) this._loadPreferences();
    this.update();
    this._next = $('.next', this.el);
    this._previous = $('.previous', this.el);
    this.setStep();
    this.center();
    return this;
  },

  displayTitle : function() {
    return 'Embed "' + Inflector.truncate(this.embedDoc.get('title'), 40) + '"';
  },

  preview : function() {
    var options = encodeURIComponent(JSON.stringify(this.embedOptions));
    var url = '/documents/' + this.embedDoc.canonicalId() + '/preview?options=' + options;
    window.open(url);
    return false;
  },

  update : function() {
    this._toggleDimensions();
    this._savePreferences();
    this._renderEmbedCode();
  },

  _savePreferences : function() {
    // var userOpts = $('form.publish_options', this.el).serializeJSON();
    // dc.app.preferences.set({'embed_options': JSON.stringify(userOpts)});
  },

  _loadPreferences : function() {
    // var userOpts = JSON.parse(dc.app.preferences.get('embed_options')) || {};
    // this.setOptions(userOpts);
  },

  _renderEmbedCode : function() {
    var $form = $('form.publish_options', this.el);
    var userOpts = {};

    userOpts['viewer_size'] = $('input[name=viewer_size]:checked', $form).val();
    if (userOpts['viewer_size'] == 'fixed') {
      userOpts['width'] = parseInt($('input[name=width]', $form).val(), 10)   || null;
      userOpts['height'] = parseInt($('input[name=height]', $form).val(), 10) || null;
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
                         this.fixedOptions :
                         this.fullscreenOptions;

    var options = $.extend({}, defaultOptions, userOpts);

    if (options['viewer_size'] == 'full') {
      delete options['width'];
      delete options['height'];
    }

    var renderedOptions = _.map(options, function(value, key) {
      return key + ": " + (typeof value == 'string' ? "\""+value+"\"" : value);
    });
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({
      doc: this.embedDoc,
      options: renderedOptions.join(',&#10;    ')
    }));

    this.embedOptions = options;
  },

  _toggleDimensions : function() {
    var view = $('select[name=viewer_size]', this.el);
    $('.dimensions', this.el).toggle(view.val() == 'fixed');
  },

  _selectViewerSize : function() {
    var viewer = $('input[name=viewer_size]:checked').val();
  },

  saveUpdatedAttributes : function() {
    var changes = {};

    var relatedArticle = $('input[name=related_article]', this.el).val() || null;
    var isPublic = $('input[name=access_level]', this.el).is(':checked');
    var remoteUrl = $('input[name=remote_url]', this.el).val() || null;

    if (this.embedDoc.get('related_article') != relatedArticle) {
      changes['related_article'] = relatedArticle;
    }
    if (this.embedDoc.get('access') != dc.access.PUBLIC && isPublic) {
      changes['access'] = dc.access.PUBLIC;
    }
    if (this.embedDoc.get('remote_url') != remoteUrl) {
      changes['remote_url'] = remoteUrl;
    }

    if (!_.isEmpty(changes)) {
      this._next.text('Saving...');
      this._next.setMode('not', 'enabled');

      var options = {
        success: _.bind(function() {
          this._next.text('Next Step');
          dc.ui.spinner.hide();
          this.nextStep(null, true);
        }, this)
      };
      dc.ui.spinner.show();
      Documents.update(this.embedDoc, changes, options);
    } else {
      this.nextStep(null, true);
    }
  },

  nextStep : function(e, skipSave) {
    if (!skipSave && this.currentStep == 1) {
      this.saveUpdatedAttributes();
      return;
    }
    if (this.currentStep >= this.totalSteps) return this.close();
    this.currentStep += 1;
    this.setStep();
  },

  previousStep : function() {
    if (this.currentStep > 1) this.currentStep -= 1;
    this.setStep();
  },

  setStep : function() {
    $('.publish_step', this.el).setMode('not', 'enabled');
    $('.publish_step_'+this.currentStep, this.el).setMode('is', 'enabled');

    this.title(this.STEPS[this.currentStep - 1]);
    this.info('Step ' + this.currentStep + ' of ' + this.totalSteps, true);

    var first = this.currentStep == 1;
    var last = this.currentStep == this.totalSteps;

    this._previous.setMode(first ? 'not' : 'is', 'enabled');
    this._next.html(last ? 'Finish' : 'Next &raquo;').setMode('is', 'enabled');
  },

  selectSnippet : function() {
    $('.snippet', this.el).select();
  }

});