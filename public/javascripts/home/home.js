$(function() {

  window.HomePage = Backbone.View.extend({

    el : document.body,

    events : {
      'keydown #search_box':   'maybeSearch',
      'search #search_box':    'search',
      'focus #search_box':     'addFocus',
      'blur #search_box':      'removeFocus',
      'click .cancel_search':  'cancelSearch',
      'click #contact_button': 'contact'
    },

    initialize : function() {
      this.box = $('#search_box');
      this.box.placeholder();
    },

    contact : function() {
      dc.ui.Dialog.contact();
    },

    search : function() {
      var query = this.box.val();
      if (query) window.location = '/public/#search/' + encodeURIComponent(query);
    },

    cancelSearch : function() {
      this.box.val('');
    },

    maybeSearch : function(e) {
      if (e.keyCode == 13) this.search();
    },

    addFocus : function() {
      $('#search_box_wrapper').addClass('focus');
    },

    removeFocus : function() {
      $('#search_box_wrapper').removeClass('focus');
    }

  });

  window.homepage = new HomePage();

});