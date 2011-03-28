dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  QUOTABLE_CATEGORIES : [
    'project'
  ],
  
  events : {
    'click'         : 'enableEdit',
    'focus'         : 'enableEdit',
    'keydown input' : 'maybeDisableEdit',
    'blur input'    : 'disableEdit',
    'change input'  : 'disableEdit'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'onSelect');
  },
  
  render : function() {
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      category   : this.options.category,
      facetQuery : this.options.facetQuery
    }));
    
    this.box = this.$('input');
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    _.defer(_.bind(function() {
      this.box.autoGrowInput();
    }, this));
    
    this.setupAutocomplete();
    
    return this;
  },
  
  setupAutocomplete : function() {
    var lookup = this.lookupValues();
    
    this.$('input').autocomplete({
      onSelect : this.onSelect,
      lookup   : lookup,
      minChars : 0,
      width    : 200
    });
  },

  lookupValues : function() {
    var category = this.options.category;
    var values = [];
    
    if (category == 'account') {
      values = Accounts.map(function(a) { return [a.get('slug'), a.fullName()]; });
    } else if (category == 'project') {
      values = Projects.pluck('title');
    } else if (category == 'filter') {
      values = ['published', 'annotated', 'public'];
    }
    
    if (_.isArray(values[0])) {
      values = {
        'data'        : _.map(values, function(v) { return v[0]; }),
        'suggestions' : _.map(values, function(v) { return v[1]; })
      };
    }
    
    return values;
  },
  
  onSelect : function(value, data) {
    this.box.val(data || value);
  },
  
  serialize : function() {
    var category = this.options.category;
    var query    = dc.inflector.trim(this.options.facetQuery);
    
    if (_.contains(this.QUOTABLE_CATEGORIES, category) && query) query = '"' + query + '"';
    
    if (category != 'text') {
      category = category + ': ';
    } else {
      category = "";
    }
    
    return category + query + ' ';
  },
  
  enableEdit : function(clearValue) {
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.box.val(this.options.facetQuery).focus().trigger('update').keyup();
      _.defer(_.bind(function() {
        if (clearValue) this.box.val('').keyup();
      }, this));
      
      dc.app.searchBox.addFocus();
    }
  },
  
  maybeDisableEdit : function(e) {
    if (e.keyCode == 13) { // Enter key
      this.disableEdit();
      dc.app.searchBox.searchEvent(e);
    }
    if (dc.app.hotkeys.shift && e.keyCode == 9) { // Tab key
      e.preventDefault();
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (e.keyCode == 9) {
      e.preventDefault();
      dc.app.searchBox.focusNextFacet(this, 1);
    }
  },
  
  disableEdit : function() {
    var newFacetQuery = this.$('input').val();
    if (newFacetQuery != this.options.facetQuery) {
      this.options.facetQuery = newFacetQuery;
    }
    this.setMode('not', 'editing');
    this.render();
    dc.app.searchBox.removeFocus();
  }
   
});