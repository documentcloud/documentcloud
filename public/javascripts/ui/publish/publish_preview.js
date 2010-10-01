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
    dc.ui.Dialog.call(this, {mode : 'custom', title : this.displayTitle()});
    this.setMode('embed', 'dialog');
    this.render();
  },

  render : function() {
    if (dc.app.organization.demo) return dc.ui.Dialog.alert(this.DEMO_ERROR);
    dc.ui.Dialog.prototype.render.call(this);
    this.$('.custom').html(JST['workspace/publish_preview']({doc: this.model}));
    this._next          = this.$('.next');
    this._previous      = this.$('.previous');
    this._widthEl       = this.$('input[name=width]');
    this._heightEl      = this.$('input[name=height]');
    this._viewerSizeEl  = this.$('select[name=viewer_size]');
    this._sidebarEl     = this.$('input[name=sidebar]');
    if (dc.app.preferences.get('embed_options')) this._loadPreferences();
    this.update();
    this.setStep();
    this.center();
    return this;
  },

  displayTitle : function() {
    if (this.currentStep == 1) return 'Step One: Review "' + Inflector.truncate(this.model.get('title'), 25) + '"';
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
    this.$('.publish_embed_code').html(JST['document/embed_dialog']({
      doc: this.model,
      options: serialized.join(',&#10;    ')
    }));
  },

  _toggleDimensions : function() {
    this.$('.dimensions').toggle(this._viewerSizeEl.val() == 'fixed');
  },

  saveUpdatedAttributes : function() {
    var access = this.$('input[name=access_level]').is(':checked') ? dc.access.PUBLIC : this.model.get('access');
    var attrs = {
      access          : access,
      related_article : Inflector.normalizeUrl(this.$('input[name=related_article]').removeClass('error').val()),
      remote_url      : Inflector.normalizeUrl(this.$('input[name=remote_url]').removeClass('error').val())
    };
    if (attrs = this.model.changedAttributes(attrs)) {
      var errors = _.any(['related_article', 'remote_url'], _.bind(function(attr) {
        if (attrs[attr] && !this.validateUrl(attrs[attr])) {
          this.$('input[name=' + attr + ']').addClass('error');
          return true;
        }
      }, this));
      if (errors) return false;
      dc.ui.spinner.show();
      this.model.save(attrs, {success : function(){ dc.ui.spinner.hide(); }});
    }
    return true;
  },

  nextStep : function() {
    if (this.currentStep == 1 && !this.saveUpdatedAttributes()) return false;
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

    this.$('.publish_step').setMode('not', 'enabled');
    this.$('.publish_step_'+this.currentStep).setMode('is', 'enabled');
    this.info('Step ' + this.currentStep + ' of ' + this.totalSteps, true);

    var first = this.currentStep == 1;
    var last = this.currentStep == this.totalSteps;

    this._previous.setMode(first ? 'not' : 'is', 'enabled');
    this._next.html(last ? 'Finish' : 'Next &raquo;').setMode('is', 'enabled');
  },

  selectSnippet : function() {
    this.$('.snippet').select();
  }

});