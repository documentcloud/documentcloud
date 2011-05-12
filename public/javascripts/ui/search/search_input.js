dc.ui.SearchInput = Backbone.View.extend({

  type : 'text',
  
  className : 'search_input',
  
  PREFIXES : [
    { label: 'project',       category: '' },
    { label: 'text',          category: '' },
    { label: 'title',         category: '' },
    { label: 'description',   category: '' },
    { label: 'source',        category: '' },
    { label: 'account',       category: '' },
    { label: 'document',      category: '' },
    { label: 'filter',        category: '' },
    { label: 'group',         category: '' },
    { label: 'access',        category: '' },
    { label: 'related',       category: '' },
    { label: 'projectid',     category: '' },
    { label: 'city',          category: 'entities' },
    { label: 'country',       category: 'entities' },
    { label: 'term',          category: 'entities' },
    { label: 'state',         category: 'entities' },
    { label: 'person',        category: 'entities' },
    { label: 'place',         category: 'entities' },
    { label: 'organization',  category: 'entities' },
    { label: 'email',         category: 'entities' },
    { label: 'phone',         category: 'entities' }
  ],

  events : {
    'keypress input'            : 'maybeSearch',
    'keydown input'             : 'keydown',
    // 'search input'           : 'searchEvent',
    'focus input'               : 'addFocus',
    'blur input'                : 'removeFocus'
  },

  render : function() {
    $(this.el).html(JST['workspace/search_input']({}));
    this.box = this.$('input');
    this.setupAutocomplete();
    
    // This is defered so it can be attached to the DOM to get the correct font-size.
    this.box.autoGrowInput();
    this.box.bind('updated.autogrow', _.bind(this.moveAutocomplete, this));
    return this;
  },
  
  setupAutocomplete : function() {
    this.box.autocomplete({
      minLength : 1,
      delay     : 50,
      autoFocus : true,
      source    : _.bind(function(req, resp) {
        // Autocomplete only last word.
        var lastWord = req.term.match(/\w+$/);
        var re = $.ui.autocomplete.escapeRegex(lastWord && lastWord[0] || ' ');
        // Only match from the beginning of the word.
        var matcher = new RegExp('^' + re, 'i');
        var matches = $.grep(this.PREFIXES, function(item) {
          return matcher.test(item.label);
        });
        resp(_.sortBy(matches, function(match) {
          return match.category + '-' + match.label;
        }));
      }, this),
      select    : _.bind(function(e, ui) {
        console.log(['select autocomplete', e, ui]);
        e.preventDefault();
        e.stopPropagation();
        dc.app.searchBox.addFacet(ui.item.value, '', this);
        this.clear();
        return false;
      }, this)
    });
    
    this.box.data('autocomplete')._renderMenu = function(ul, items) {
      // Renders the results under the categories they belong to.
      var category = '';
      _.each(items, _.bind(function(item, i) {
        if (item.category && item.category != category) {
          ul.append('<li class="ui-autocomplete-category">' + item.category + '</li>');
          category = item.category;
        }
        this._renderItem(ul, item);
      }, this));
    };
    
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
  
  closeAutocomplete : function() {
    var autocomplete = this.box.data('autocomplete');
    if (autocomplete) autocomplete.close();
  },

  focus : function() {
    this.box.focus();
  },
  
  blur : function() {
    this.box.blur();
  },
  
  // Callback fired on key press in the search box. We search when they hit return.
  maybeSearch : function(e) {
    // console.log(['box key', e.keyCode, dc.app.hotkeys.key(e)]);
    if (dc.app.hotkeys.key(e) == 'enter') {
      return dc.app.searchBox.searchEvent(e);
    }

    if (dc.app.hotkeys.colon(e)) {
      this.box.trigger('resize.autogrow', e);
      var query = this.box.val();
      if (_.contains(_.pluck(this.PREFIXES, 'label'), query)) {
        e.preventDefault();
        dc.app.searchBox.addFacet(query, '', this);
        this.clear();
        return false;
      }
    }
  },
  
  addFocus : function() {
    dc.app.searchBox.addFocus();
  },

  removeFocus : function() {
    dc.app.searchBox.removeFocus();
  },
  
  clear : function() {
    this.box.val('');
  },
  
  value : function() {
    return this.box.val();
  },
  
  keydown : function(e) {
    dc.app.hotkeys.down(e);
    // console.log(['box keydown', e.keyCode, e.which, this.box.getCursorPosition(), this.allSelected]);
    this.box.trigger('resize.autogrow', e);
    
    if (!dc.app.hotkeys.backspace && this.allSelected) {
      this.allSelected = false;
      this.disableFacets();
    }
    
    if (dc.app.hotkeys.key(e) == 'left') {
      if (this.box.getCursorPosition() == 0) {
        e.preventDefault();
        this.focusNextFacet(this.facetViews.length-1, 0, -1);
      }
    } else if (dc.app.hotkeys.shift && dc.app.hotkeys.tab) {
      e.preventDefault();
      this.focusNextFacet(this.facetViews.length-1, 0);
    } else if (dc.app.hotkeys.tab) {
      e.preventDefault();
      this.focusNextFacet(null, 0);
    } else if (dc.app.hotkeys.backspace) {
      if (this.allSelected) {
        e.preventDefault();
        this.cancelSearch();
        this.allSelected = false;
      } else if (this.box.getCursorPosition() == 0 && !this.box.getSelection().length) {
        e.preventDefault();
        this.focusNextFacet(this.facetViews.length-1, 0, -1, true);
      }
    } else if (dc.app.hotkeys.command && (e.which == 97 || e.which == 65)) {
      e.preventDefault();
      this.selectAllFacets();
    }
  }
  
});