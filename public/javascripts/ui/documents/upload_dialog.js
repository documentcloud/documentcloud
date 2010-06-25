dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',

  callbacks : {
    '.ok.click':      'confirm',
    '.cancel.click':  'close'
  },

  constructor : function() {
    _.bindAll(this, '_onUploadStarted', '_onUploadCompleted', '_updateProgress');
    this.base({
      mode      : 'custom',
      title     : "Upload a Document"
    });
  },

  render : function() {
    $(this.el).hide();
    this.base({noOverlay : true});
    this._project = Projects.firstOwnedAndSelected();
    $('.custom', this.el).html(JST.upload_dialog({
      project : this._project
    }));
    $('.cancel', this.el).text('Close');
    $('.ok', this.el).text('Upload');
    return this;
  },

  confirm : function() {
    if (!$('#document_upload_title', this.el).val()) {
      return this.error('Please enter a title for the document.');
    };
    $('#upload_document', this.el).submit();
    _.defer(_.bind(function(){
      this._progressDialog = dc.ui.Dialog.progress('The document is uploading, please leave this window open.');
    }, this));
    this.close();
  },

  closeUpload : function() {
    if (this._progressDialog) this._progressDialog.close();
  },

  open : function() {
    this.render();
    $(this.el).show();
    $(document.body).addClass('overlay');
    this.center();
  },

  close : function() {
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  }

});
