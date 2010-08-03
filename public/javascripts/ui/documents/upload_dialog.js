dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',
  className: 'dialog docalog',

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
    this._project = _.first(Projects.selected());
    $('.custom', this.el).html(JST['document/upload_dialog']({
      project : this._project
    }));
    $('.cancel', this.el).text('Close');
    $('.ok', this.el).text('Upload');
    $('.document_upload_browse').uploadify({
      uploader     : '/flash/uploadify.swf',
      script       : '/import/upload_document',
      auto         : true,
      multi        : true,
      wmode        : 'transparent',
      fileDataName : 'file',
      scriptData   : { 
        'session_key' : dc.app.cookies.get('document_cloud_session')
      }
    });
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
    $('#document_upload_title', this.el).focus();
  },

  close : function() {
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  }

});
