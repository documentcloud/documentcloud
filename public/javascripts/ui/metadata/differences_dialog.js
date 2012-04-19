dc.ui.DifferencesDialog = dc.ui.Dialog.extend({

  id : 'differences_dialog',

  events : {
    'click .ok':  'confirm'
  },

  constructor : function(documents) {
    this.documents = documents;
    dc.ui.Dialog.call(this, {
      mode        : 'custom',
      title       : 'View Differences'
    });
    dc.ui.spinner.show();
    this._loadText();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this.$('.custom').html(JST['document/differences']({docs : this.documents}));
    this.center();
    return this;
  },

  _loadText : function() {
  }

});