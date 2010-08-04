dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',
  className: 'dialog docalog',
  
  uploadDocumentTiles : {},

  callbacks : {
    '.ok.click':      'confirm',
    '.cancel.click':  'close'
  },

  constructor : function() {
     _.bindAll(this, '_onSelect', '_onSelectOnce', '_onCancel', '_onOpen', '_onProgress', '_onComplete', '_onAllComplete');
    this.base({
      mode      : 'custom',
      title     : "Upload Documents"
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
    
    this.scriptData = { 
      'session_key' : dc.app.cookies.get('document_cloud_session')
    };
    if (this._project) {
      this.scriptData['project_id'] = this._project.id;
    }
    
    this.$uploadify = $('#document_upload_browse', this.el);
    this.$uploadify.uploadify({
      uploader      : '/flash/uploadify.swf',
      script        : '/import/upload_document',
      auto          : false,
      multi         : true,
      wmode         : 'transparent',
      fileDataName  : 'file',
      scriptData    : this.scriptData,
      onSelect      : this._onSelect,
      onSelectOnce  : this._onSelectOnce,
      onCancel      : this._onCancel,
      onOpen        : this._onOpen,
      onProgress    : this._onProgress,
      onComplete    : this._onComplete,
      onAllComplete : this._onAllComplete
    });
    
    return this;
  },
  
  _onSelect : function(e, queueId, fileObj) {
    this.uploadDocumentTiles[queueId] = (new dc.ui.UploadDocumentTile({'queueId': queueId, 'fileObj': fileObj})).render();
    var title = $('input[name=title]', this.uploadDocumentTiles[queueId].el).val();
    console.log(['Select', title, queueId]);
    this.$uploadify.uploadifySettings('scriptData', {'title': title});
    // Return false so that Uploadify does not create it's own progress bars.
    return false;
  },
  
  _onSelectOnce : function(e, data) {
    $('.ok', this.el).text('Upload ' + data.fileCount + Inflector.pluralize(' Document', data.fileCount));
  },
  
  _onCancel : function(e, queueId, fileObj, data) {
    this._onSelectOnce(e, data);
  },
  
  _onOpen : function(e, queueId, fileObj) {
    var title = $('input[name=title]', this.uploadDocumentTiles[queueId].el).val();
    
    console.log(['Uploading', title, queueId, this.uploadDocumentTiles[queueId]]);
    this.$uploadify.uploadifySettings('scriptData', {'title': title});
  },
  
  _onProgress : function(e, queueId, fileObj, data) {
    console.log(['Progress', queueId, data]);
  },
  
  _onComplete : function(e, queueId, fileObj, response, data) {
    console.log(['Complete', e, queueId, fileObj, response, data]);
    $('#hidden_iframe').html(response);
  },
  
  _onAllComplete : function(e, data) {
    this.close();
  },

  confirm : function() {
    var $queuedDocument = $('.upload_document_queue input[name=title]', this.el);
    var $noTitle = $(_.select($queuedDocument, function(s) { 
      return $.trim($(s).val()) == ''; 
    }));
    $queuedDocument.removeClass('error');
    
    if ($noTitle.length) {
      $noTitle.addClass('error');
      var error_text = 'Please enter a title for all documents.';
      if ($queuedDocument.length == 1) {
        error_text = 'Please enter a title for the document.';
      }
      return this.error(error_text);
    };
    
    this.$uploadify.uploadifyUpload();
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
  },
  
  _addDocument : function(e, doc) {
    var view = new dc.ui.Document({model : doc});
    $(this.el).prepend(view.render().el);
  },

  _removeDocument : function(e, doc) {
    $('#document_' + doc.id).remove();
  }

});

dc.ui.UploadDocumentTile = dc.View.extend({
  
  className : 'upload_document_queue',
  
  callbacks : {
    '.upload_close.click' : 'removeUploadFile'
  },
  
  constructor : function(options) {
    _.bindAll(this, 'removeUploadFile');
    this.base(options);
    this.queueId = options['queueId'];
    this.fileObj = options['fileObj'];
  },
  
  render : function() {
    $(this.el).html(JST['document/upload_document_tile']({
      'documentQueueId' : this.queueId,
      'documentFileObj' : this.fileObj
    }));
    $('.upload_document_tiles').append(this.el);
    
    this.setCallbacks();
    
    return this;
  },
  
  removeUploadFile : function() {
    var self = this;
    dc.app.uploader.$uploadify.uploadifyCancel(this.queueId);
    $(this.el).animate({opacity: 0}, {duration: 300, complete: function() {
      $(self.el).slideUp(200);
    }});
  }
  
});