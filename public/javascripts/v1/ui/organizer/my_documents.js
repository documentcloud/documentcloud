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
    dc.app.searchBox.search('documents: ' + Accounts.current().get('email'));
  }

});


dc.ui.MyNotes = dc.View.extend({

  className : 'my_notes box serif',

  callbacks : [
    ['el',  'click',  'showNotes']
  ],

  sortKey : 'My Notes',

  render : function() {
    $(this.el).html(JST.organizer_my_notes({title : 'My Notes'}));
    this.setCallbacks();
    return this;
  },

  showNotes : function() {
    dc.app.searchBox.search('notes: ' + Accounts.current().get('email'));
  }

});
