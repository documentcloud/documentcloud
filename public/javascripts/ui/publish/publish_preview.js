dc.ui.PublishPreview = dc.ui.Dialog.extend({

  callbacks : {
    '.preview.click'  : 'preview',
    'input.change'    : 'update',
    'select.change'   : 'update',
    'input.keyup'     : 'update',
    'input.focus'     : 'update',
    'input.click'     : 'update',
    '.next.click'     : 'nextStep',
    '.previous.click' : 'previousStep',
    '.close.click'    : 'close',
    '.snippet.click'  : 'selectSnippet'
  },

  totalSteps : 3,

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
    this._next          = $('.next', this.el);
    this._previous      = $('.previous', this.el);
    this._widthEl       = $('input[name=width]', this.el);
    this._heightEl      = $('input[name=height]', this.el);
    this._viewerSizeEl  = $('select[name=viewer_size]', this.el);
    this._sidebarEl     = $('input[name=sidebar]', this.el);
    if (dc.app.preferences.get('embed_options')) this._loadPreferences();
    this.update();
    this.setStep();
    this.center();
    return this;
  },

  displayTitle : function() {
    return 'Embed "' + Inflector.truncate(this.embedDoc.get('title'), 40) + '"';
  },

  preview : function() {
    var options = encodeURIComponent(JSON.stringify(this.embedOptions()));
    var url = '/documents/' + this.embedDoc.canonicalId() + '/preview?options=' + options;
    window.open(url);
    return false;
  },

  update : function() {
    this._toggleDimensions();
    this._savePreferences();
    this._renderEmbedCode();
  },

  embedOptions : function() {
    var options = {};
    if (this._viewerSizeEl.val() == 'fixed') {
      var width   = parseInt(this._widthEl.val(), 10);
      var height  = parseInt(this._heightEl.val(), 10);
      if (width)  options.width  = width;
      if (height) options.height = height;
    }
    if (!this._sidebarEl.is(':checked')) options.sidebar = false;
    return options;
  },

  _savePreferences : function() {
    dc.app.preferences.set({embed_options : JSON.stringify(this.embedOptions())});
  },

  _loadPreferences : function() {
    var options = JSON.parse(dc.app.preferences.get('embed_options') || this.DEFAULT_OPTIONS);
    if (options.width || options.height) this._viewerSizeEl.val('fixed');
    this._widthEl.val(options.width);
    this._heightEl.val(options.height);
    this._sidebarEl.attr('checked', options.sidebar === false ? false : true);
  },

  _renderEmbedCode : function() {
    var options       = this.embedOptions();
    options.container = '"#' + this.embedDoc.canonicalId() + '"';
    var serialized    = _.map(options, function(value, key){ return key + ': ' + value; });
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({
      doc: this.embedDoc,
      options: serialized.join(',&#10;    ')
    }));
  },

  _toggleDimensions : function() {
    $('.dimensions', this.el).toggle(this._viewerSizeEl.val() == 'fixed');
  },

  saveUpdatedAttributes : function() {
    var access = $('input[name=access_level]', this.el).is(':checked') ? dc.access.PUBLIC : this.embedDoc.get('access');
    var attrs = {
      access          : access,
      related_article : $('input[name=related_article]', this.el).val() || null,
      remote_url      : $('input[name=remote_url]', this.el).val()      || null
    };
    if (attrs = this.embedDoc.changedAttributes(attrs)) {
      dc.ui.spinner.show();
      Documents.update(this.embedDoc, attrs, {success : function(){ dc.ui.spinner.hide(); }});
    }
  },

  nextStep : function() {
    if (this.currentStep == 1) this.saveUpdatedAttributes();
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