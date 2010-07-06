// The Help tab.
dc.ui.Help = dc.View.extend({

  callbacks : {
    '.contact_us.click': 'openContactDialog'
  },

  constructor : function() {
    this.el = $('#help')[0];
  },

  render : function() {
    this._toolbar = $('#help_toolbar');
    this._toolbar.prepend(this._createHelpMenu().render().el);
    this.setCallbacks();
    return this;
  },

  openContactDialog : function() {
    dc.ui.Dialog.prompt('Contact Us', '', function(message) {
      $.post('/help/contact_us', {message : message}, function() {
        dc.ui.notifier.show({mode : 'info', text : 'Your message was sent successfully.'});
      });
      return true;
    }, {information : "Send a message and we'll email you back.", saveText : 'Send'});
  },

  openPage : function(resource) {
    $.get("/help/" + resource + '.html', function(resp) {
      $('#help_content').html(resp);
    });
  },

  _createHelpMenu : function() {
    return this._helpMenu = new dc.ui.Menu({
      id      : 'how_to_menu',
      label   : 'Guides &amp; How To\'s',
      items   : [
        {title : 'Search Documents',       onClick : _.bind(this.openPage, this, 'search')},
        {title : 'Add Users',              onClick : _.bind(this.openPage, this, 'add_users')},
        {title : 'Upload Documents',       onClick : _.bind(this.openPage, this, 'import')},
        {title : 'Annotate',               onClick : _.bind(this.openPage, this, 'notes')},
        {title : 'Embed &amp; Publish',    onClick : _.bind(this.openPage, this, 'publish')},
        {title : 'Troubleshoot Documents', onClick : _.bind(this.openPage, this, 'troubleshoot')}
      ]
    });
  }

});