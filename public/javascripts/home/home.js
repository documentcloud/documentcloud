$(function() {

  window.HomePage = Backbone.View.extend({

    FAVORITES_URL : '//twitter.com/favorites/documentcloud.json?callback=?',

    el : document.body,

    events : {
      'keydown #search_box':   'maybeSearch',
      'search #search_box':    'search',
      'focus #search_box':     'addFocus',
      'blur #search_box':      'removeFocus',
      'click .cancel_search':  'cancelSearch',
      'click #login_button':   'login'
    },

    initialize : function() {
      dc.ui.notifier      = new dc.ui.Notifier();
      this.box            = $('#search_box');
      this.emailInput     = $('#account_email');
      this.passwordInput  = $('#account_password');
      _.invoke([this.box, this.emailInput, this.passwordInput], 'placeholder');
      $(_.bind(this.loadTweets, this));
    },

    login : function() {
      $('#login_form').submit();
    },

    search : function() {
      var query = this.box.val();
      if (query) window.location = (window.serverRoot || '') + '/public/search/' + encodeURIComponent(query);
    },

    cancelSearch : function() {
      this.box.val('');
    },

    maybeSearch : function(e) {
      if (e.which == 13) this.search();
    },

    addFocus : function() {
      $('#search_box_wrapper').addClass('focus');
    },

    removeFocus : function() {
      $('#search_box_wrapper').removeClass('focus');
    },

    loadTweets : function() {
      if (!$(document.body).hasClass('homepage')) return;
      var formatDate = DateUtils.create("%b %e, %Y");
      $.getJSON(this.FAVORITES_URL, function(json) {
        var tweets = json.slice(0, 3);
        var html   = "";
        _.each(tweets, function(tweet, i) {
          html += JST['home/tweet'](_.extend(tweet, {
            index: i,
            date : formatDate(new Date(Date.parse(tweet.created_at)))
          }));
        });
        $('#tweets').html(html).show();
      });
    }

  });

  window.homepage = new HomePage();

});