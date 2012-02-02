// The Help tab.
dc.ui.Help = Backbone.View.extend({

  PAGES : [
    {url : '',                 title : 'Introduction'},
    {url : 'tour',             title : 'Guided Tour'},
    {url : 'accounts',         title : 'Adding Accounts'},
    {url : 'searching',        title : 'Searching Documents and Data'},
    {url : 'uploading',        title : 'Uploading Documents'},
    {url : 'troubleshooting',  title : 'Troubleshooting Failed Uploads'},
    {url : 'modification',     title : 'Document Modification'},
    {url : 'notes',            title : 'Editing Notes and Sections'},
    {url : 'collaboration',    title : 'Collaboration'},
    {url : 'privacy',          title : 'Privacy'},
    {url : 'publishing',       title : 'Publishing &amp; Embedding'},
    {url : 'api',              title : 'The DocumentCloud API'}
  ],

  events : {
    'click .contact_us':  'openContactDialog',
    'click .uservoice':   'openUserVoice'
  },

  initialize : function() {
    this.currentPage = null;
    this.PAGE_URLS = _.pluck(this.PAGES, 'url');
  },

  render : function() {
    dc.app.navigation.bind('tab:help',  _.bind(this.openHelpTab, this));
    this._toolbar = $('#help_toolbar');
    if (dc.account) {
      this._toolbar.prepend(this._createHelpMenu().render().el);
    }
    return this;
  },

  openContactDialog : function() {
    dc.ui.Dialog.contact();
  },

  openUserVoice : function() {
    window.open('http://documentcloud.uservoice.com');
  },

  openPage : function(page) {
    var noChange = !_.include(this.PAGE_URLS, page) || (page === this.currentPage);
    this.currentPage = page;
    this.saveHistory();
    if (noChange) return dc.app.navigation.open('help');
    page || (page = dc.account ? 'index' : 'public');
    $.get("/ajax_help/" + page + '.html', function(resp) {
      $('#help_content').html(resp);
    });
    dc.app.navigation.open('help');
  },

  openHelpTab : function() {
    this.currentPage ? this.saveHistory() : this.openPage('');
  },

  saveHistory : function() {
    Backbone.history.navigate('help' + (this.currentPage ? '/' + this.currentPage : ''));
  },

  _createHelpMenu : function() {
    return this.menu = new dc.ui.Menu({
      id      : 'how_to_menu',
      label   : 'Guides &amp; How To\'s',
      items   : _.map(this.PAGES, _.bind(function(page) {
        return {onClick : _.bind(this.openPage, this, page.url), title : page.title};
      }, this))
    });
  }

});
