dc.ui.SearchFacet = Backbone.View.extend({
  
  className : 'search_facet',
  
  events : {
    'click input'                   : 'enableEdit',
    'click .category'               : 'selectFacet',
    'keydown input'                 : 'keydown',
    'blur input'                    : 'deferDisableEdit',
    'mouseover .cancel_search'      : 'showDelete',
    'mouseout .cancel_search'       : 'hideDelete',
    'click .cancel_search'          : 'remove'
  },
  
  initialize : function(options) {
    this.setMode('not', 'editing');
    _.bindAll(this, 'set', 'keydown', 'deselectFacet');
  },
  
  render : function() {
    console.log(['search facet', this.model.get('value')]);
    var $el = this.$el = $(this.el);
    $el.html(JST['workspace/search_facet']({
      model : this.model
    }));
    this.setMode('not', 'editing');
    this.box = this.$('input');
    
    return this;
  },
  
  // This is defered from the searchBox so it can be attached to the 
  // DOM to get the correct font-size.
  calculateSize : function() {
    this.box.autoGrowInput();
    this.box.unbind('updated.autogrow').bind('updated.autogrow', _.bind(this.moveAutocomplete, this));
  },
  
  setupAutocomplete : function() {
    var data = this.autocompleteValues();

    this.box.autocomplete({
      source    : data,
      minLength : 0,
      delay     : 0,
      autoFocus : true,
      select    : _.bind(function(e, ui) {
        console.log(['autocomplete facet', ui.item.value]);
        e.preventDefault();
        var originalValue = this.model.get('value');
        this.set(ui.item.value);
        if (originalValue != ui.item.value) this.search(e);
        return false;
      }, this)
    });
    
    this.box.autocomplete('widget').addClass('interface');
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
  
  set : function(value) {
    if (!value) return;
    // this.box.data('autocomplete').close();
    console.log(['set facet', value, this.model.get('value'), this.model]);
    this.model.set({'value': value});
  },
  
  search : function(e) {
    this.closeAutocomplete();
    dc.app.searchBox.searchEvent(e);
  },
  
  enableEdit : function(e) {
    this.canClose = false;
    console.log(['enableEdit', e, this.model.get('category'), !this.$el.hasClass('is_editing')]);
    if (this.modes.editing != 'is') {
      this.setMode('is', 'editing');
      this.deselectFacet(e);
      this.setupAutocomplete();
      if (this.box.val() == '') {
        this.box.val(this.model.get('value'));
      }
      this.searchAutocomplete();
      this.box.focus();
      dc.app.searchBox.addFocus();
    }
    this.box.trigger('resize.autogrow');
    dc.app.searchBox.disableFacets(this);
  },
  
  deferDisableEdit : function(e) {
    this.canClose = true;
    console.log(['deferDisableEdit', e]);
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
    this.box.blur();
    // this.box.val(newFacetQuery);
    this.closeAutocomplete();
  },
  
  selectFacet : function(e, selectAll) {
    console.log(['selectFacet', this.box, selectAll]);
    this.canClose = false;
    this.box.setCursorPosition(0);
    if (this.box.is(':focus')) this.box.blur();
    this.setMode('is', 'selected');
    this.setMode('not', 'editing');
    this.closeAutocomplete();
    if (!selectAll) {
      dc.app.searchBox.addFocus();
      $(document).unbind('keydown.facet', this.keydown);
      $(document).unbind('click.facet', this.deselectFacet);
      _.defer(_.bind(function() {
        $(document).unbind('keydown.facet').bind('keydown.facet', this.keydown);
        $(document).unbind('click.facet').one('click.facet', this.deselectFacet);
      }, this));
      dc.app.searchBox.disableFacets(this);
    }
  },
  
  deselectFacet : function(e) {
    console.log(['deselectFacet', this.box, e]);
    this.setMode('not', 'selected');
    this.closeAutocomplete();
    $(document).unbind('keydown.facet', this.keydown);
    $(document).unbind('click.facet', this.deselectFacet);
  },
  
  searchAutocomplete : function(e) {
    console.log(['searchAutocomplete', e]);
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.search();
  },
  
  closeAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.close();
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
  },
  
  setCursorAtEnd : function(direction) {
    if (direction == -1) {
      this.box.setCursorPosition(this.box.val().length);
    } else {
      this.box.setCursorPosition(0);
    }
  },
  
  remove : function(e) {
    console.log(['remove facet', e, this.model]);
    var committed = this.model.has('value');
    this.deselectFacet();
    this.disableEdit();
    SearchQuery.remove(this.model);
    Backbone.View.prototype.remove.call(this);
    if (committed) {
      this.search(e);
    } else {
      dc.app.searchBox.renderQuery();
      dc.app.searchBox.focusNextFacet(this, -1);
    }
  },
  
  keydown : function(e) {
    dc.app.hotkeys.down(e);
    console.log(['keydown', e.which, this.box.val(), this.box.getCursorPosition(), dc.app.hotkeys.left, dc.app.hotkeys.right]);
    if (dc.app.hotkeys.enter && this.box.val()) {
      this.disableEdit(e);
      this.search(e);
    } else if (dc.app.hotkeys.left) {
      if (this.box.getCursorPosition() == 0) {
        if (this.modes.selected == 'is' && this.options.order > 0) {
          this.disableEdit(e);
          dc.app.searchBox.focusNextFacet(this, -1);
          e.preventDefault();
          this.deselectFacet();
        } else {
          this.selectFacet();
        }
        return false;
      }
    } else if (dc.app.hotkeys.right) {
      if (this.modes.selected == 'is') {
        e.preventDefault();
        this.deselectFacet(e);
        this.setCursorAtEnd(0);
        this.enableEdit(e);
      } else if (this.box.getCursorPosition() == this.box.val().length) {
        e.preventDefault();
        this.disableEdit(e);
        dc.app.searchBox.focusNextFacet(this, 1, false, true);
        return false;
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
        return false;
      } else if (this.box.getCursorPosition() == 0 && !this.box.getSelection().length) {
        e.preventDefault();
        this.selectFacet();
        return false;
      }
    } else if (dc.app.hotkeys.command && (e.which == 97 || e.which == 65)) {
      e.preventDefault();
      dc.app.searchBox.selectAllFacets();
    }
    this.resize(e);
  },
  
  resize : function(e) {
    this.box.trigger('resize.autogrow', e);
  }
  
  
   
});