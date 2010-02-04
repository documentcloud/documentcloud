dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',

  callbacks : {
    '.ok.click':      'confirm',
    '.cancel.click':  'close'
  },

  constructor : function() {
    this.base({
      mode      : 'custom',
      title     : "Upload Documents",
      onClose   : function(){ dc.ui.UploadDialog._openDialog = null; }
    });
    this.render();
  },

  render : function() {
    this.base();
    $('.custom', this.el).html(JST.upload_dialog({
      organization: dc.app.organization.name
    }));
    this.setCallbacks();
    return this;
  }

}, {

  open : function() {
    if (this._openDialog) return false;
    this._openDialog = new this();
  }

});