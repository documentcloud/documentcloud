dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  events : {
    'click'                    : 'enableEdit',
    // 'focus input'              : 'enableEdit',
    'keypress input'           : 'maybeDisableEdit',
    'blur input'               : 'deferDisableEdit',
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
    
    return this;
  },
  
  calculateSize : function() {
    // This is defered so it can be attached to the DOM to get the correct font-size.
    this.box.autoGrowInput();
    this.box.bind('autogrow:updated', _.bind(this.moveAutocomplete, this));
  },
  
  setupAutocomplete : function() {
    var data = this.autocompleteValues();
    
    this.box.autocomplete({
      source    : data,
      minLength : 0,
      delay     : 0,
      select    : _.bind(function(e, ui) {
        console.log(['autocomplete', e, ui]);
        e.preventDefault();
        this.set(ui.item.value, e);
        return false;
      }, this)
    });
  },
  
  moveAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) {
      autocomplete.menu.element.position({
        my: "left top",
        at: "left bottom",
        of: this.box.data('autocomplete').element,
        collision: "none"
      });
    }
  },
  
  set : function(value, e) {
    if (!value) return;
    // this.box.data('autocomplete').close();
    if (this.model.get('value') != value) {
      console.log(['set facet', value, this.model.get('value'), this.model]);
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
        this.box.val(this.model.get('value'));
      }
      this.box.focus().click();
      dc.app.searchBox.addFocus();
    }
    this.box.trigger('update');
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
  
  deferDisableEdit : function(e) {
    console.log(['deferDisableEdit', e]);
    _.delay(_.bind(function() {
      if (!this.box.is(':focus') && this.modes.editing == 'is') {
        this.disableEdit(e);
      }
    }, this), 250);
  },
  
  disableEdit : function(e) {
    // e.preventDefault();
    console.log(['disableEdit', e, this.box.val()]);
    var newFacetQuery = dc.inflector.trim(this.box.val());
    this.set(newFacetQuery);
    this.setMode('not', 'editing');
    this.box.blur();
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.close();
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
      values = Accounts.map(function(a) { return {value: a.get('slug'), label: a.fullName()}; });
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