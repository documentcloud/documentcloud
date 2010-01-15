dc.ui.MyDocuments = dc.View.extend({

  className : 'my_documents box serif',

  callbacks : [
    ['el',  'click',  'showDocuments']
  ],

  sortKey : 'My Documents',

  render : function() {
    $(this.el).html(JST.organizer_my_documents({title : 'My Documents'}));
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    dc.app.searchBox.search('account: ' + Accounts.current().get('email'));
  }

});
