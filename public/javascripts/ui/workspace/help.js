// The Help tab.
dc.ui.Help = dc.Controller.extend({

  PAGES : [
    {url : '',                 title : 'Introduction'},
    {url : 'searching',        title : 'Searching Documents'},
    {url : 'accounts',         title : 'Adding Accounts'},
    {url : 'uploading',        title : 'Uploading Documents'},
    {url : 'notes',            title : 'Editing Notes and Sections'},
    {url : 'publishing',       title : 'Publishing &amp; Embedding'},
    {url : 'collaboration',    title : 'Collaboration'},
    {url : 'privacy',          title : 'Privacy'},
    {url : 'troubleshooting',  title : 'Troubleshooting Failed Uploads'},
    {url : 'tour',             title : 'Guided Tour'}
  ],

  callbacks : {
    '.contact_us.click':  'openContactDialog',
    '.uservoice.click':   'openUserVoice'
  },

  constructor : function() {
    this.currentPage = null;
    this.PAGE_URLS = _.pluck(this.PAGES, 'url');
  },

  render : function() {
    this.el = $('#help')[0];
    dc.history.register(/^#help\//,     _.bind(this.openPage, this));
    dc.history.register(/^#help$/,      _.bind(this.openPage, this, ''));
    dc.app.navigation.bind('tab:help',  _.bind(this.openHelpTab, this));
    this._toolbar = $('#help_toolbar');
    this._toolbar.prepend(this._createHelpMenu().render().el);
    this.setCallbacks();
    return this;
  },

  openContactDialog : function() {
    dc.ui.Dialog.prompt('Contact Us', '', function(message) {
      $.post('/ajax_help/contact_us', {message : message}, function() {
        dc.ui.notifier.show({mode : 'info', text : 'Your message was sent successfully.'});
      });
      return true;
    }, {
      id       : 'contact_us',
      text     : 'Use this form (or email to <a href="mailto:support@documentcloud.org">support@documentcloud.org</a>) to contact us for assistance. \
                  If you need to speak to someone immediately, you can call us at (646) 450-2162.<br /> \
                  See <a href="http://www.documentcloud.org/contact">documentcloud.org/contact</a> for more ways to get in touch.',
      saveText : 'Send'
    });
  },

  openUserVoice : function() {
    window.open('http://documentcloud.uservoice.com');
  },

  openPage : function(page) {
    var noChange = !_.include(this.PAGE_URLS, page) || (page === this.currentPage);
    this.currentPage = page;
    this.saveHistory();
    if (noChange) return dc.app.navigation.open('help');
    $.get("/ajax_help/" + (page || 'index') + '.html', function(resp) {
      $('#help_content').html(resp);
    });
    dc.app.navigation.open('help');
  },

  openHelpTab : function() {
    this.currentPage ? this.saveHistory() : this.openPage('');
  },

  saveHistory : function() {
    dc.history.save('help/' + (this.currentPage || ''));
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