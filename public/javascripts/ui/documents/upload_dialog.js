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
    this.base();
    this._project = Projects.selected()[0];
    $('.custom', this.el).html(JST.upload_dialog({
      project : this._project
    }));
    $('.cancel', this.el).text('close');
    $('.ok', this.el).text('upload');
    return this;
  },

  confirm : function() {
    if (!$('#document_upload_title', this.el).val()) {
      return dc.ui.Dialog.alert('Please enter a title for the document.');
    };
    dc.ui.spinner.show('uploading');
    $('#upload_info', this.el).show();
    $('#upload_document', this.el).submit();
    return false;
  },

  cancelUpload : function() {
    dc.ui.spinner.hide();
    $('#upload_info', this.el).hide();
  },

  confirmUpload : function() {
    dc.ui.spinner.hide();
    dc.app.documentCount += 1;
    dc.ui.Project.uploadedDocuments.render();
    this.close();
  },

  open : function() {
    this.render();
    $(this.el).show();
    this.center();
  },

  close : function() {
    $(this.el).hide();
  }

});
