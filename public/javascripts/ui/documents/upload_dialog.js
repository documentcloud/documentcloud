dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',
  className: 'dialog docalog',
    
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

  render : function() {
    this.base();
    this.uploadDocumentTiles = {};
    this._project = _.first(Projects.selected());
    console.log(['render', this._project]);

    $('.custom', this.el).html(JST['document/upload_dialog']({
      project : this._project
    }));
    $('.cancel', this.el).text('Cancel');
    
    this._renderDocumentTiles();
    
    return this;
  },
  
  _renderDocumentTiles : function() {
    var $tiles = $('.upload_document_tiles', this.el);
    
    _.each(UploadDocuments.models(), _.bind(function(uploadDocumentModel) {
      var view = new dc.ui.UploadDocumentTile({
        model : uploadDocumentModel
      });
      this.uploadDocumentTiles[uploadDocumentModel.id] = view.render();
    }, this));
    var views = _.pluck(_.values(this.uploadDocumentTiles), 'el');
    console.log(['render views', views]);
    $tiles.append(views);
      
  },
  
  setupUploadify : function() {
    this.$uploadify = $('#new_document');
    
    var options = {
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
      scriptData    : {},
      onInit        : this._onInit,
      onSelect      : this._onSelect,
      onSelectOnce  : this._onSelectOnce,
      onCancel      : this._onCancel,
      onStarted     : this._onStarted,
      onProgress    : this._onProgress,
      onComplete    : this._onComplete,
      onAllComplete : this._onAllComplete
    };
    
    this.$uploadify.uploadify(options);
  },
  
  _onInit : function() {
    
  },
  
  _onSelect : function(e, queueId, fileObj) {
    console.log(['onSelect', queueId, fileObj, UploadDocuments.size()]);
    var model = new dc.model.UploadDocument({
      id: queueId,
      file: fileObj,
      position: UploadDocuments.size()
    });
    UploadDocuments.add(model);
    
    // Return false so that Uploadify does not create it's own progress bars.
    return false;
  },
  
  _onSelectOnce : function(e, data) {
    this.render();
  },
  
  _onCancel : function(e, queueId, fileObj, data) {
    console.log(['Cancel', e, queueId, fileObj, data, this]);
    
    return false;
  },
  
  _onStarted : function(e, queueId) {
    var options = this.uploadDocumentTiles[queueId].serialize();
    
    UploadDocuments.get(queueId).set(options);
    
    options['session_key'] = dc.app.cookies.get('document_cloud_session');

    if (this._project) {
      options['project_id'] = this._project.id;
    }
    
    this.$uploadify.uploadifySettings('scriptData', options);
  },
  
  _onProgress : function(e, queueId, fileObj, data) {
    this.uploadDocumentTiles[queueId].setProgress(data.percentage);
    
    // Return false so uploadify doesn't try to update missing fields (from onSelect)
    return false;
  },
  
  _onComplete : function(e, queueId, fileObj, response, data) {
    console.log(['Complete', e, queueId, fileObj, response, data]);
    response = JSON.parse(response);
    
    if (response['bad_request']) {
      return this.error("Upload failed.");
    } else {
      var doc = new top.dc.model.Document(response['document']);
      Documents.add(doc);
      if (this._project) {
        Projects.incrementCountById(this._project.id);
      }
    }
    
    this.uploadDocumentTiles[queueId].hide();
  },
  
  _onAllComplete : function(e, data) {
    this.close();
  },

  confirm : function() {
    var failed = _.select(this.uploadDocumentTiles, function(view) {
      return view.ensureTitle();
    });
    
    if (failed.length) {
      return this.error(UploadDocuments.size() == 1 ? 
                        'Please enter a title for the document.' :
                        'Please enter a title for all documents.');
    }
    
    $('.ok', this.el).text('Uploading...');
    $('.ok', this.el).setMode('not', 'enabled');
    this.$uploadify.uploadifyUpload();
  },

  open : function() {
    $(this.el).show();
    $(document.body).addClass('overlay');
    this.center();
  },
  
  cancel : function() {
    this.$uploadify.uploadifyClearQueue();
    this.close();
  },
  
  close : function() {
    UploadDocuments.refresh();
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
  
  render : function() {
    console.log(['tile render']);
    $(this.el).html(JST['document/upload_document_tile']({
      'model' : this.model
    }));
    console.log(['tile render 2']);
    
    this.setCallbacks();
    
    console.log(['tile render 3', this]);
    return this;
  },
  
  serialize : function() {
    return {
      title: $('input[name=title]', this.el).val(),
      description: $('textarea[name=description]', this.el).val(),
      source: $('input[name=source]', this.el).val(),
      access: $('input[name=access]', this.el).val()
    };
  },
  
  removeUploadFile : function() {
    console.log(['Remove file', dc.app.uploader.$uploadify, this.queueId, this.el]);
    dc.app.uploader.$uploadify.uploadifyCancel(this.model.id);
    this.hide();
  },
  
  openEdit : function() {    
    $('.upload_edit', this.el).toggle();
    $('.open_edit', this.el).toggleClass('active');
  },
  
  setProgress : function(percentage) {
    var $progress = $('.upload_progress_bar_container', this.el);
    $progress.animate({'width': percentage + '%'}, {'queue': false, 'duration': 150});
  },
  
  ensureTitle : function() {
    var $queuedDocument = $('input[name=title]', this.el);
    var noTitle = $.trim($queuedDocument.val()) == '';
    $queuedDocument.toggleClass('error', noTitle);
    
    console.log(['ensureTitle', noTitle]);
    return noTitle;
  },
  
  hide : function() {
    var $file = $(this.el);
    $file.animate({opacity: 0}, {
      duration: 300, 
      complete: function() {
        $file.slideUp(200);
      }
    });
  }
    
});
