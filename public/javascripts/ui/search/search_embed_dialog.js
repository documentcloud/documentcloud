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
    width      : null,
    order      : 'page_count',
    per_page   : 10,
    search_bar : false,
    title      : null
  },
  
  constructor : function() {
    this.query       = dc.app.searcher.box.value();
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
      publicCount     : this.documentsCount - this.restrictedCount
    }));
    this._next          = this.$('.next');
    this._previous      = this.$('.previous');
    this._widthEl       = this.$('input[name=width]');
    this._embedSizeEl   = this.$('select[name=embed_size]');
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
        query   : this.query,
        slug    : Inflector.sluggify(this.query),
        options : options
    });
    var url = '/search/preview?' + params;
    window.open(url);
    return false;
  },

  update : function() {
    this._toggleDimensions();
    this._renderPerPageLabel();
    this._renderEmbedCode();
  },

  embedOptions : function() {
    var options = {};
    if (this._embedSizeEl.val() == 'fixed') {
      var width = parseInt(this._widthEl.val(), 10);
      if (width) options.width = width;
    }
    options.q          = this.query;
    options.container  = 'DC-search-' + Inflector.sluggify(this.query);
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
    if (options.width) {
      this._embedSizeEl.val('fixed');
      this._widthEl.val(options.width);
    } else {
      this._embedSizeEl.val('full');
      this._widthEl.val('');
    }
    this._orderEl.val(options.order);
    this._perPageEl.val(options.per_page);
    this._searchBarEl.val([options.search_bar ? 'true' : 'false']);
    console.log(['_loadPreferences', options.search_bar]);
  },

  _renderEmbedCode : function() {
    var options       = this.embedOptions();
    var title         = this._titleEl.val();
    options.container = '"#DC-search-' + Inflector.sluggify(this.query) + '"';
    options.query     = '"' + this.query + '"';
    options.order     = '"' + options.order + '"';
    if (title && title.length) {
      options.title   = '"' + title.replace(/\"/g, '\\\"') + '"';
    }
    var serialized    = _.map(options, function(value, key){ return key + ': ' + value; });
    this.$('.publish_embed_code').html(JST['search/embed_dialog']({
      query: Inflector.sluggify(this.query),
      options: serialized.join(',&#10;    ')
    }));
  },

  _toggleDimensions : function() {
    this.$('.dimensions').toggle(this._embedSizeEl.val() == 'fixed');
  },
  
  _renderPerPageLabel : function() {
    var perPage = this._perPageEl.val();
    var $label  = this.$('.publish_option_perpage_sidelabel');
    var label;
    
    if (!perPage || !parseInt(perPage, 10)) {
      label = '';
    } else {
      var pages = Math.ceil(this.documentsCount / perPage);
      var label = [
        this.documentsCount,
        Inflector.pluralize(' document', this.documentsCount),
        ' on ',
        pages,
        Inflector.pluralize(' page', pages),
        '.'
      ].join('');
    }
    
    $label.text(label);
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