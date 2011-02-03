dc.ui.SearchEmbedDialog = dc.ui.Dialog.extend({

  events : {
    'click .preview'        : 'preview',
    'change select'         : 'update',
    'click select'          : 'update',
    'keyup input'           : 'update',
    'focus input'           : 'update',
    'click input'           : 'update',
    'change input'          : 'update',
    'click .next'           : 'nextStep',
    'click .previous'       : 'previousStep',
    'click .close'          : 'close',
    'click .snippet'        : 'selectSnippet'
  },

  totalSteps : 3,

  STEPS : [null, null,
    'Step Two: Configure the Document Viewer',
    'Step Three: Copy and Paste the Embed Code'
  ],

  DEMO_ERROR : 'Demo accounts are not allowed to embed searches. <a href="/contact">Contact us</a> if you need a full featured account. View an example of the embed code <a href="http://dev.dcloud.org/help/publishing#step_4">here</a>.',

  DEFAULT_OPTIONS : {
    width  : 600,
    order  : 'score'
  },
  
  constructor : function() {
    this.query       = dc.app.searcher.box.value();
    this.currentStep = 1;
    
    dc.ui.Dialog.call(this, {mode : 'custom', title : this.displayTitle()});
    this.fetchCounts();
  },
  
  fetchCounts : function() {
    $.ajax({
      url  : '/search/documents_count.json',
      data : {q: this.query},
      dataType : 'json',
      success : _.bind(function(resp) {
        this.privateCount  = resp.private_count;
        this.documentsCount = resp.documents_count;
        this.render();
      }, this)
    });
  },

  render : function() {
    if (dc.account.organization.demo) return dc.ui.Dialog.alert(this.DEMO_ERROR);
    dc.ui.Dialog.prototype.render.call(this);
    this.$('.custom').html(JST['workspace/search_embed_dialog']({
      query          : this.query,
      privateCount   : this.privateCount,
      documentsCount : this.documentsCount
    }));
    this._next          = this.$('.next');
    this._previous      = this.$('.previous');
    this._widthEl       = this.$('input[name=width]');
    this._viewerSizeEl  = this.$('select[name=viewer_size]');
    this._sidebarEl     = this.$('input[name=sidebar]');
    this._showTextEl    = this.$('input[name=show_text]');
    this._openToEl      = this.$('.open_to');
    if (dc.app.preferences.get('search_embed_options')) this._loadPreferences();
    this.setMode('embed', 'dialog');
    this.update();
    this.setStep();
    this.center();
    return this;
  },

  displayTitle : function() {
    if (this.currentStep == 1) return 'Step One: Review "' + Inflector.truncate(this.query, 25) + '"';
    return this.STEPS[this.currentStep];
  },

  preview : function() {
    var options = encodeURIComponent(JSON.stringify(this.embedOptions()));
    var url = '/documents/' + this.query + '/preview?options=' + options;
    window.open(url);
    return false;
  },

  update : function() {
    this._toggleDimensions();
    this._renderEmbedCode();
  },

  embedOptions : function() {
    var options = {};
    if (this._viewerSizeEl.val() == 'fixed') {
      var width   = parseInt(this._widthEl.val(), 10);
      if (width)  options.width  = width;
    }
    // TODO: Add order
    return options;
  },

  _savePreferences : function() {
    dc.app.preferences.set({search_options : JSON.stringify(this.embedOptions())});
  },

  _loadPreferences : function() {
    var options = JSON.parse(dc.app.preferences.get('search_embed_options')) || this.DEFAULT_OPTIONS;
    if (options.width) this._viewerSizeEl.val('fixed');
    this._widthEl.val(options.width);
  },

  _renderEmbedCode : function() {
    var options       = this.embedOptions();
    options.container = '"#search-' + this.query + '"';
    var serialized    = _.map(options, function(value, key){ return key + ': ' + value; });
    this.$('.publish_embed_code').html(JST['search/embed_dialog']({
      query: this.query,
      options: serialized.join(',&#10;    ')
    }));
  },

  _toggleDimensions : function() {
    this.$('.dimensions').toggle(this._viewerSizeEl.val() == 'fixed');
  },

  nextStep : function() {
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