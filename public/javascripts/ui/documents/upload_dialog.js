dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',
  className: 'dialog docalog',
  
  uploadDocumentTiles : {},

  callbacks : {
    '.ok.click':      'confirm',
    '.cancel.click':  'cancel'
  },

  constructor : function() {
     _.bindAll(this, '_onInit', '_onSelect', '_onSelectOnce', '_onCancel', '_onStarted', '_onProgress', '_onComplete', '_onAllComplete');
    this.base({
      mode      : 'custom',
      title     : 'Upload Documents'
    });
  },
  
  setupUploadify : function(options) {
    this.$uploadify = $('#new_document');
    
    var defaults = {
      uploader      : '/flash/uploadify.swf',
      script        : '/import/upload_document',
      auto          : false,
      multi         : true,
      wmode         : 'transparent',
      fileDataName  : 'file',
      buttonImg     : '/images/embed/ui/spacer.png',
      buttonImg     : '/images/help/drag_select.png',
      width         : 126,
      height        : 26,
      scriptData    : this.scriptData,
      onInit        : this._onInit,
      onSelect      : this._onSelect,
      onSelectOnce  : this._onSelectOnce,
      onCancel      : this._onCancel,
      onStarted     : this._onStarted,
      onProgress    : this._onProgress,
      onComplete    : this._onComplete,
      onAllComplete : this._onAllComplete
    };
    var uploadifyOptions = $.extend({}, defaults, options);
    
    this.$uploadify.uploadify(uploadifyOptions);
  },

  render : function() {
    $(this.el).hide();
    this.base({noOverlay : true});
    this._project = _.first(Projects.selected());
    $('.custom', this.el).html(JST['document/upload_dialog']({
      project : this._project
    }));
    $('.cancel', this.el).text('Cancel');
    $('.ok', this.el).text('Upload');
    
    this.uploadDocumentTiles = {};
    
    this.scriptData = { 
      'session_key' : dc.app.cookies.get('document_cloud_session')
    };
    if (this._project) {
      this.scriptData['project_id'] = this._project.id;
    }
    
    $('.ok', this.el).setMode('not', 'enabled');
    
    this.setupUploadify();
    
    return this;
  },
  
  _onInit : function() {
    
  },
  
  _onSelect : function(e, queueId, fileObj) {
    this.uploadDocumentTiles[queueId] = (new dc.ui.UploadDocumentTile({
      'queueId': queueId, 
      'fileObj': fileObj
    })).render();
    
    // Return false so that Uploadify does not create it's own progress bars.
    return false;
  },
  
  _onSelectOnce : function(e, data) {
    var $submit = $('.ok', this.el);
    
    if (data.fileCount > 0) {
      $submit.setMode('is', 'enabled');
      if (data.fileCount == 1) {
        $submit.text('Upload Document');
      } else {
        $submit.text('Upload ' + data.fileCount + ' Documents');
      }
    } else {
      $submit.setMode('not', 'enabled');
      $submit.text('Upload Documents');
    }
    
    this.open();
    this.center(); // TODO: Take me out.
  },
  
  _onCancel : function(e, queueId, fileObj, data) {
    console.log(['Cancel', e, queueId, fileObj, data, this]);
    
    delete this.uploadDocumentTiles[queueId];
    this._onSelectOnce(e, data);
    
    return false;
  },
  
  _onStarted : function(e, queueId) {
    var title = $('input[name=title]', this.uploadDocumentTiles[queueId].el).val();
    var description = $('textarea[name=description]', this.uploadDocumentTiles[queueId].el).val();
    var source = $('input[name=source]', this.el).val();
    var access = $('input[name=access]', this.el).val();
    
    this.$uploadify.uploadifySettings('scriptData', {
      'title': title,
      'source': source,
      'description': description,
      'access': access
    });
  },
  
  _onProgress : function(e, queueId, fileObj, data) {
    var $progress = $('.upload_progress_bar_container', this.uploadDocumentTiles[queueId].el);
    $progress.animate({'width': data.percentage + '%'}, {'queue': false, 'duration': 150});
    
    // Return false so uploadify doesn't try to update missing fields (from onSelect)
    return false;
  },
  
  _onComplete : function(e, queueId, fileObj, response, data) {
    console.log(['Complete', e, queueId, fileObj, response, data]);
    response = eval('(' + response + ')');
    
    if (response['bad_request']) {
      var title = $('input[name=title]', this.uploadDocumentTiles[queueId].el).val();
      dc.ui.Dialog.alert('Upload failed. Please check the document: ' + title);
    } else {
      var doc = new top.dc.model.Document(response['document']);
      Documents.add(doc);
      if (this._project) {
        Projects.incrementCountById(this._project.id);
      }
    }
    
    var $file = $(this.uploadDocumentTiles[queueId].el);
    $file.animate({opacity: 0}, {
      duration: 300, 
      complete: function() {
        $file.slideUp(200);
      }
    });
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
    
    $('.ok', this.el).text('Uploading...');
    $('.ok', this.el).setMode('not', 'enabled');
    this.$uploadify.uploadifyUpload();
  },

  open : function() {
    $(this.el).show();
    $(document.body).addClass('overlay');
    this.center();
    $('#document_upload_title', this.el).focus();
  },
  
  cancel : function() {
    if (_.keys(this.uploadDocumentTiles).length) {
      this.$uploadify.uploadifyClearQueue();
      $('.upload_document_queue').remove();
    }
    this.close();
  },
  
  close : function() {
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  }

});

dc.ui.UploadDocumentTile = dc.View.extend({
  
  className : 'upload_document_queue',
  
  callbacks : {
    '.remove_queue.click' : 'removeUploadFile',
    '.open_edit.click' : 'openEdit'
  },
  
  FILE_EXTENSION_MATCHER : /\.([^.]+)$/,
  
  constructor : function(options) {
    _.bindAll(this, 'removeUploadFile');
    this.base(options);
    this.queueId = options['queueId'];
    this.fileObj = options['fileObj'];
  },
  
  render : function() {
    var filename = this.fileObj['name'].replace(this.FILE_EXTENSION_MATCHER, '');
    var match = this.fileObj['name'].match(this.FILE_EXTENSION_MATCHER);
    var extension = match && match[1];
    
    $(this.el).html(JST['document/upload_document_tile']({
      'documentQueueId' : this.queueId,
      'documentFileObj' : this.fileObj,
      'filename': filename,
      'extension': extension
    }));
    $('.upload_document_tiles').append(this.el);
    
    this.setCallbacks();
    
    return this;
  },
  
  removeUploadFile : function() {
    dc.app.uploader.$uploadify.uploadifyCancel(this.queueId);
    $(this.el).animate({opacity: 0}, {duration: 300, complete: _.bind(function() {
      $(this.el).slideUp(200);
    }, this)});
  },
  
  openEdit : function() {
    var $edit = $('.upload_edit', this.el);
    var $editButton = $('.open_edit', this.el);
    
    $edit.toggle();
    $editButton.toggleClass('active');
  }
  
});