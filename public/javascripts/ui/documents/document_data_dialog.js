dc.ui.DocumentDataDialog = dc.ui.Dialog.extend({

  className : 'dialog datalog',

  dataEvents : {
    'click .minus':   '_removeDatum',
    'click .plus':    '_addDatum'
  },

  constructor : function(docs) {
    this.events = _.extend({}, this.events, this.dataEvents);
    this.removedKeys = [];
    this.docs = docs;
    this.multiple = docs.length > 1;
    this._rowTemplate = JST['document/data_dialog_row'];
    var title = "Edit Data for " + this._title();
    dc.ui.Dialog.call(this, {mode : 'custom', title : title, saveText : 'Save'});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    var data = Documents.sortData(Documents.sharedData(this.docs));
    this._container = this.$('.custom');
    this._container.html(JST['document/data_dialog']({multiple: this.multiple, data: data}));
    this.checkNoData();
    return this;
  },

  checkNoData : function() {
    if (!this.$('.data_row').length) {
      var container = this._container.find('.rows');
      var template  =
      container.html(
        this._rowTemplate({key: '', value: '', minus: false}) +
        this._rowTemplate({key: '', value: '', minus: true}) +
        this._rowTemplate({key: '', value: '', minus: true})
      );
    }
  },

  serialize : function() {
    var data = {};
    _.each(this.removedKeys, function(key) {
      data[key] = null;
    });
    _.each(this.$('.data_row'), function(row) {
      data[$(row).find('.key').val()] = $(row).find('.value').val();
    });
    return data;
  },

  confirm : function() {
    var data = this.serialize();
    _.each(this.docs, function(doc){ doc.mergeData(data); });
    this.close();
  },

  _removeDatum : function(e) {
    var row = $(e.target).closest('.data_row');
    this.removedKeys.push(row.find('.key').val());
    row.remove();
    this.checkNoData();
  },

  _addDatum : function(e) {
    var newRow = $(this._rowTemplate({key: '', value: '', minus: true}));
    $(e.target).closest('.data_row').after(newRow);
    newRow.find('.key').focus();
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
