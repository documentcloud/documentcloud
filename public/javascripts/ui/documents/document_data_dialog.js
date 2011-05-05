dc.ui.DocumentDataDialog = dc.ui.Dialog.extend({

  className : 'dialog datalog',

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Edit Data for " + this._title();
    dc.ui.Dialog.call(this, {mode : 'custom', title : title, saveText : 'Save'});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    this._container.html(JST['document/document_data_dialog']({
      data: Documents.sortData(Documents.sharedData(this.docs))
    }));
    return this;
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
