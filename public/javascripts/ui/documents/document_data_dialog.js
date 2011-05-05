dc.ui.DocumentDataDialog = dc.ui.Dialog.extend({

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Edit Data for " + this._title();
    dc.ui.Dialog.call(this, {mode : 'custom', title : title, editor : true});
    this.render();
    $(document.body).append(this.el);
  },

  // Sets the dialog title to include the number of documents or title of
  // the single document being edited.
  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + dc.inflector.truncate(this.docs[0].get('title'), 35) + '"';
  }

}, {

  // This static method is used for conveniently opening the dialog for
  // any selected documents.
  open : function(doc) {
    var docs = Documents.chosen(doc);
    if (!docs.length) return;
    if (!Documents.allowedToEdit(docs)) return;
    new dc.ui.DocumentDataDialog(docs);
  }

});
