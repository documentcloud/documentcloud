dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  events : {
    'click'                    : 'enableEdit',
    'focus input'              : 'searchAutocomplete',
    'keydown input'            : 'keydown',
    'blur input'               : 'deferDisableEdit',
    // 'change input'             : 'disableEdit',
    'mouseover .cancel_search' : 'showDelete',
    'mouseout .cancel_search'  : 'hideDelete',
    'click .cancel_search'     : 'remove'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'set', 'keydown');
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
    this.box.unbind('updated.autogrow').bind('updated.autogrow', _.bind(this.moveAutocomplete, this));
  },
  
  selectFacet : function() {
    this.canClose = false;
    this.box.blur();
    this.setMode('is', 'selected');
    this.closeAutocomplete();
    _.defer(_.bind(function() {
      $(document).bind('keydown.facet', this.keydown);
      $(document).bind('click.facet', _.bind(this.deselectFacet, this));
    }, this));
  },
  
  deselectFacet : function() {
    this.setMode('not', 'selected');
    this.closeAutocomplete();
    $(document).unbind('keydown.facet');
    $(document).bind('click.facet');
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
        this.search(e);
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
    console.log(['set facet', value, this.model.get('value'), this.model]);
    this.model.set({'value': value});
  },
  
  search : function(e) {
    dc.app.searchBox.searchEvent(e);
  },
  
  enableEdit : function(e) {
    this.canClose = false;
    console.log(['enableEdit', e, this.model.get('category'), !this.$el.hasClass('is_editing')]);
    if (!this.$el.hasClass('is_editing')) {
      this.setMode('is', 'editing');
      this.deselectFacet();
      
      this.setupAutocomplete();
      if (this.box.val() == '') {
        this.box.val(this.model.get('value'));
      }
      this.box.focus().click();
      dc.app.searchBox.addFocus();
    }
    this.box.trigger('resize.autogrow');
  },
  
  searchAutocomplete : function() {
    this.deselectFacet();
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.search();
  },
  
  closeAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.close();
  },
  
  setCursorPosition : function(direction) {
    if (direction == -1) {
      this.box.setCursorPosition(this.box.val().length);
    } else {
      this.box.setCursorPosition(0);
    }
  },
  
  keydown : function(e) {
    dc.app.hotkeys.down(e);
    console.log(['keydown', e.keyCode, dc.app.hotkeys.right, this.box.val(), this.box.getCursorPosition()]);
    if (dc.app.hotkeys.enter && this.box.val()) {
      this.disableEdit(e);
      this.search(e);
    } else if (dc.app.hotkeys.left) {
      if (this.box.getCursorPosition() == 0) {
        if (this.modes.selected == 'is') {
          this.disableEdit(e);
          dc.app.searchBox.focusNextFacet(this, -1);
          e.preventDefault();
          this.deselectFacet();
        } else {
          this.selectFacet();
        }
      }
    } else if (dc.app.hotkeys.right) {
      if (this.modes.selected == 'is') {
        e.preventDefault();
        this.deselectFacet();
        this.setCursorPosition(0);
      } else if (this.box.getCursorPosition() == this.box.val().length) {
        e.preventDefault();
        this.disableEdit(e);
        dc.app.searchBox.focusNextFacet(this, 1, false, true);
      }
    } else if (dc.app.hotkeys.shift && dc.app.hotkeys.tab) {
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, -1);
    } else if (dc.app.hotkeys.tab) {
      e.preventDefault();
      this.disableEdit(e);
      dc.app.searchBox.focusNextFacet(this, 1);
    } else if (dc.app.hotkeys.backspace) {
      if (this.modes.selected == 'is') {
        e.preventDefault();
        this.remove(e);
      } else if (this.box.getCursorPosition() == 0 && !this.box.getSelection().length) {
        e.preventDefault();
        this.selectFacet();
        return false;
      }
    }
    
    this.box.trigger('resize.autogrow', e);
  },
  
  deferDisableEdit : function(e) {
    this.canClose = true;
    // console.log(['deferDisableEdit', e]);
    _.delay(_.bind(function() {
      if (this.canClose && !this.box.is(':focus') && this.modes.editing == 'is' && this.modes.selected != 'is') {
        this.disableEdit(e);
      }
    }, this), 250);
  },
  
  disableEdit : function(e) {
    // e.preventDefault();
    console.log(['disableEdit', e, this.box.val()]);
    var newFacetQuery = dc.inflector.trim(this.box.val());
    if (newFacetQuery != this.model.get('value')) {
      this.set(newFacetQuery);
    }
    this.setMode('not', 'editing');
    this.deselectFacet();
    this.box.blur();
    this.closeAutocomplete();
  },
  
  remove : function(e) {
    console.log(['remove facet', e, this.model]);
    var committed = this.model.has('value');
    SearchQuery.remove(this.model);
    Backbone.View.prototype.remove.call(this);
    this.deselectFacet();
    if (committed) {
      this.search(e);
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