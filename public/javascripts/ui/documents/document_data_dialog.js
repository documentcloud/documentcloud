dc.ui.DocumentDataDialog = dc.ui.Dialog.extend({

  className : 'dialog datalog',

  dataEvents : {
    'click .minus':       '_removeDatum',
    'click .plus':        '_addDatum',
    'click .remove_all':  '_removeAll'
  },

  constructor : function(docs) {
    this.events       = _.extend({}, this.events, this.dataEvents);
    this.docs         = docs;
    this.multiple     = docs.length > 1;
    this.originalData = Documents.sharedData(this.docs);
    this._rowTemplate = JST['document/data_dialog_row'];
    dc.ui.Dialog.call(this, {mode : 'custom', title : "Edit Data for " + this._title(), saveText : 'Save'});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    var data = Documents.sortData(this.originalData);
    var removeAll = _.any(this.docs, function(doc){ return !_.isEmpty(doc.get('data')); });
    this._container = this.$('.custom');
    this._container.html(JST['document/data_dialog']({
      multiple  : this.multiple,
      removeAll : removeAll,
      data      : data
    }));
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
    _.each(this.$('.data_row'), function(row) {
      data[$(row).find('.key').val()] = $(row).find('.value').val();
    });
    return data;
  },

  confirm : function() {
    var data = this.serialize();
    var forbidden = _.detect(_.keys(data), function(key){ return _.include(dc.searchPrefixes, key); });
    if (forbidden) {
      this.error('"' + forbidden + '" cannot be used as a key');
    } else {
      var toRemove = _.without.apply(_, [_.keys(this.originalData)].concat(_.keys(data)));
      _.each(this.docs, function(doc){ doc.mergeData(data, toRemove); });
      this.close();
    }
  },

  _removeDatum : function(e) {
    $(e.target).closest('.data_row').remove();
    this.checkNoData();
  },

  _addDatum : function(e) {
    var newRow = $(this._rowTemplate({key: '', value: '', minus: true}));
    $(e.target).closest('.data_row').after(newRow);
    newRow.find('.key').focus();
    this.checkNoData();
  },

  _removeAll : function() {
    _.each(this.docs, function(doc){ doc.save({data: {}}); });
    this.close();
  },

  // Sets the dialog title to include the number of documents or title of
  // the single document being edited.
  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + dc.inflector.truncate(this.docs[0].get('title'), 25) + '"';
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
