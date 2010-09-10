dc.ui.PublishPreview = dc.ui.Dialog.extend({

  callbacks : {
    '.preview.click'  : 'preview',
    'select.change'   : 'update',
    'select.click'    : 'update',
    'input.keyup'     : 'update',
    'input.focus'     : 'update',
    'input.click'     : 'update',
    'input.change'    : 'update',
    '.next.click'     : 'nextStep',
    '.previous.click' : 'previousStep',
    '.close.click'    : 'close',
    '.snippet.click'  : 'selectSnippet'
  },

  totalSteps : 3,

  STEPS : [null, null,
    'Step Two: Configure the Document Viewer',
    'Step Three: Copy and Paste the Embed Code'
  ],

  DEMO_ERROR : 'Demo accounts are not allowed to embed documents. <a href="/contact">Contact us</a> if you need a full featured account. View an example of the embed code <a href="http://dev.dcloud.org/help/publishing#step_4">here</a>.',

  constructor : function(doc) {
    this.model = doc;
    this.currentStep = 1;
    this.base({mode : 'custom', title : this.displayTitle()});
    this.setMode('embed', 'dialog');
    this.render();
  },

  render : function() {
    if (dc.app.organization.demo) return dc.ui.Dialog.alert(this.DEMO_ERROR);
    this.base();
    $('.custom', this.el).html(JST['workspace/publish_preview']({doc: this.model}));
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
    if (this.currentStep == 1) return 'Step One: Review "' + Inflector.truncate(this.model.get('title'), 30) + '"';
    return this.STEPS[this.currentStep];
  },

  preview : function() {
    var options = encodeURIComponent(JSON.stringify(this.embedOptions()));
    var url = '/documents/' + this.model.canonicalId() + '/preview?options=' + options;
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
    options.container = '"#viewer-' + this.model.canonicalId() + '"';
    var serialized    = _.map(options, function(value, key){ return key + ': ' + value; });
    $('.publish_embed_code', this.el).html(JST['document/embed_dialog']({
      doc: this.model,
      options: serialized.join(',&#10;    ')
    }));
  },

  _toggleDimensions : function() {
    $('.dimensions', this.el).toggle(this._viewerSizeEl.val() == 'fixed');
  },

  saveUpdatedAttributes : function() {
    var access = $('input[name=access_level]', this.el).is(':checked') ? dc.access.PUBLIC : this.model.get('access');
    var attrs = {
      access          : access,
      related_article : $('input[name=related_article]', this.el).val() || null,
      remote_url      : $('input[name=remote_url]', this.el).val()      || null
    };
    if (attrs = this.model.changedAttributes(attrs)) {
      dc.ui.spinner.show();
      Documents.update(this.model, attrs, {success : function(){ dc.ui.spinner.hide(); }});
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
    this.title(this.displayTitle());

    $('.publish_step', this.el).setMode('not', 'enabled');
    $('.publish_step_'+this.currentStep, this.el).setMode('is', 'enabled');
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