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
    'click .snippet'        : 'selectSnippet',
    'click .change_access'  : 'changeAccess'
  },

  totalSteps : 3,

  STEPS : [null, null,
    'Step Two: Configure the Document Set',
    'Step Three: Copy and Paste the Embed Code'
  ],

  DEMO_ERROR : 'Demo accounts are not allowed to embed document sets. <a href="/contact">Contact us</a> if you need a full featured account. View an example of the embed code <a href="http://dev.dcloud.org/help/publishing#step_4">here</a>.',

  DEFAULT_OPTIONS : {
    order      : 'title',
    per_page   : 12,
    search_bar : false,
    title      : null,
    q          : ''
  },
  
  constructor : function() {
    this.query       = dc.app.searcher.publicQuery() || "";
    this.currentStep = 1;
    
    dc.ui.Dialog.call(this, {mode : 'custom', title : this.displayTitle()});
    dc.ui.spinner.show();
    this.fetchCounts();
  },
  
  fetchCounts : function() {
    $.ajax({
      url  : '/search/restricted_count.json',
      data : {q: this.query},
      dataType : 'json',
      success : _.bind(function(resp) {
        this.restrictedCount = resp.restricted_count;
        this.documentsCount  = dc.app.paginator.query.total;
        this.publicCount     = this.documentsCount - this.restrictedCount;
        this.render();
      }, this)
    });
  },

  render : function() {
    if (dc.account.organization.demo) return dc.ui.Dialog.alert(this.DEMO_ERROR);
    dc.ui.Dialog.prototype.render.call(this);
    this.$('.custom').html(JST['workspace/search_embed_dialog']({
      query           : this.query,
      restrictedCount : this.restrictedCount,
      documentsCount  : this.documentsCount,
      publicCount     : this.publicCount
    }));
    this._next          = this.$('.next');
    this._previous      = this.$('.previous');
    this._orderEl       = this.$('select[name=order]');
    this._perPageEl     = this.$('input[name=per_page]');
    this._titleEl       = this.$('input[name=title]');
    this._searchBarEl   = this.$('input[name=search_bar]');
    this._loadPreferences();
    this.setMode('embed', 'dialog');
    this.setMode('search_embed', 'dialog');
    this.update();
    this.setStep();
    this.center();
    dc.ui.spinner.hide();
    return this;
  },

  displayTitle : function() {
    if (this.currentStep == 1) return 'Step One: Review "' + Inflector.truncate(this.query, 25) + '"';
    return this.STEPS[this.currentStep];
  },

  preview : function() {
    var options = JSON.stringify(this.embedOptions());
    var params = $.param({
        q       : this.query,
        slug    : Inflector.sluggify(this.query),
        options : options
    });
    var url = '/search/preview?' + params;
    window.open(url);
    return false;
  },

  update : function() {
    this._renderPerPageLabel();
    this._renderEmbedCode();
  },

  embedOptions : function() {
    var options = {};
    options.q          = this.query;
    options.container  = 'DC-search-' + Inflector.sluggify(this.query);
    options.title      = this._titleEl.val().replace(/\"/g, '\\\"');
    options.order      = this._orderEl.val();
    options.per_page   = this._perPageEl.val();
    options.search_bar = this._searchBarEl.filter(':checked').val() == 'true';
    return options;
  },

  _savePreferences : function() {
    dc.app.preferences.set({search_embed_options : JSON.stringify(this.embedOptions())});
  },

  _deletePreferences : function() {
    dc.app.preferences.remove('search_embed_options');
  },

  _loadPreferences : function() {
    var options = _.extend({}, this.DEFAULT_OPTIONS, JSON.parse(dc.app.preferences.get('search_embed_options')));
    this._orderEl.val(options.order);
    this._perPageEl.val(options.per_page);
    this._searchBarEl.val([options.search_bar ? 'true' : 'false']);
  },

  _renderEmbedCode : function() {
    var options       = this.embedOptions();
    options.title     = '"' + options.title + '"';
    options.container = '"#DC-search-' + Inflector.sluggify(options.q) + '"';
    options.q         = '"' + options.q + '"';
    options.order     = '"' + options.order + '"';
    var serialized    = _.map(options, function(value, key){ return key + ': ' + value; });
    this.$('.publish_embed_code').html(JST['search/embed_dialog']({
      query: Inflector.sluggify(this.query),
      options: serialized.join(',&#10;    ')
    }));
  },

  _renderPerPageLabel : function() {
    var perPage = this._perPageEl.val();
    var $label  = this.$('.publish_option_perpage_sidelabel');
    var label;
    
    if (!perPage || !parseInt(perPage, 10)) {
      label = '&nbsp;';
    } else {
      var pages = Math.max(1, Math.ceil(this.publicCount / perPage));
      var label = [
        this.publicCount,
        Inflector.pluralize(' document', this.publicCount),
        ' on ',
        pages,
        Inflector.pluralize(' page', pages)
      ].join('');
    }
    
    $label.html(label);
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
  },
  
  changeAccess : function() {
    var restrictedQuery = this.query;
    if (restrictedQuery.indexOf('filter:restricted') == -1) {
      restrictedQuery += ' filter:restricted';
    }
    dc.app.searcher.search(restrictedQuery);
    this.close();
  }

});