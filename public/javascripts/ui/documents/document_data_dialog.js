dc.ui.DocumentDataDialog = dc.ui.Dialog.extend({

  className : 'dialog datalog',

  dataEvents : {
    'click .minus':   '_removeDatum',
    'click .plus':    '_addDatum'
  },

  constructor : function(docs) {
    this.events = _.extend(this.events, this.dataEvents);
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
    var html = _.map(Documents.sortData(Documents.sharedData(this.docs)), function(pair){
      return JST['document/data_dialog_row']({key: pair[0], value: pair[1], minus: true});
    }).join('');
    this._container.html(html);
    this.checkNoData();
    return this;
  },

  checkNoData : function() {
    if (!this.$('.data_row').length) {
      this._container.html(JST['document/data_dialog_row']({key: '', value: '', minus: false}));
    }
  },

  _removeDatum : function(e) {
    $(e.target).closest('.data_row').remove();
    this.checkNoData();
  },

  _addDatum : function(e) {
    $(e.target).closest('.data_row').after(JST['document/data_dialog_row']({key: '', value: '', minus: true}));
    this.checkNoData();
  },

  // Sets the dialog title to include the number of documents or title of
  // the single document being edited.
  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + dc.inflector.truncate(this.docs[0].get('title'), 30) + '"';
  },

  _returnCloses : function() {
    return true;
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
