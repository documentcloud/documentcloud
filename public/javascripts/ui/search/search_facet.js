dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  events : {
    'click'                    : 'enableEdit',
    // 'focus input'              : 'enableEdit',
    'keypress input'           : 'maybeDisableEdit',
    'blur input'               : 'disableEdit',
    // 'change input'             : 'disableEdit',
    'mouseover .cancel_search' : 'showDelete',
    'mouseout .cancel_search'  : 'hideDelete',
    'click .cancel_search'     : 'remove'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'set');
  },
  
  render : function() {
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      model : this.model
    }));
    
    this.setMode('not', 'editing');
    
    this.box = this.$('input');
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    _.defer(_.bind(function() {
      this.box.autoGrowInput();
    }, this));
    
    return this;
  },
  
  setupAutocomplete : function() {
    var data = this.autocompleteValues();
    
    this.box.autocomplete(data, {
      width     : 200,
      minChars  : 0,
      autoFill  : true,
      clickFire : true,
      formatItem : function(values, i, n) {
        return values.length == 2 ? values[1] : values[0];
      },
      formatResult : function(value) {
        return value[0];
      }
    }).result(_.bind(function(e, values, data) {
      console.log(['autocomplete', values, data]);
      e.preventDefault();
      this.set(values[0], e);
      return false;
    }, this));
  },
  
  set : function(value, e) {
    console.log(['set facet', value, e, this.model]);
    if (!value) return;
    this.box.unautocomplete();
    if (this.model.get('value') != value) {
      this.model.set({'value': value});
      dc.app.searchBox.searchEvent(e);
    }
  },
  
  enableEdit : function(e) {
    console.log(['enableEdit', e, this.model.get('category'), !this.$el.hasClass('is_editing')]);
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.setupAutocomplete();
      if (this.box.val() == '') {
        this.box.val(this.model.get('value')).focus().click();
      }
      dc.app.searchBox.addFocus();
    }
  },
  
  maybeDisableEdit : function(e) {
    console.log(['maybeDisableEdit', e.keyCode, this.box.val()]);
    if (e.keyCode == 13 && this.box.val()) { // Enter key
      this.disableEdit(e);
      dc.app.searchBox.searchEvent(e);
    }
    if (dc.app.hotkeys.shift && e.keyCode == 9) { // Tab key
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (e.keyCode == 9) {
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, 1);
    }
  },
  
  disableEdit : function(e) {
    // e.preventDefault();
    console.log(['disableEdit', e, this.box.val()]);
    var newFacetQuery = this.box.val();
    this.set(newFacetQuery);
    this.setMode('not', 'editing');
    this.box.unautocomplete();
    if (!newFacetQuery) {
      this.remove();
    }
  },
  
  remove : function(e) {
    console.log(['remove facet', e]);
    var committed = this.model.has('value');
    SearchQuery.remove(this.model);
    Backbone.View.prototype.remove.call(this);
    if (committed) {
      dc.app.searchBox.searchEvent(e);
    }
  },

  autocompleteValues : function() {
    var category = this.model.get('category');
    var values = [];
    
    if (category == 'account') {
      values = Accounts.map(function(a) { return [a.get('slug'), a.fullName()]; });
    } else if (category == 'project') {
      values = Projects.pluck('title');
    } else if (category == 'filter') {
      values = ['published', 'annotated'];
    } else if (category == 'access') {
      values = ['public', 'private', 'organization'];
    }
    
    return values;
  },
  
  showDelete : function() {
    this.$el.addClass('search_facet_maybe_delete');
  },
  
  hideDelete : function() {
    this.$el.removeClass('search_facet_maybe_delete');
  }
  
  
   
});