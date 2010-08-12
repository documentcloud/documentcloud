// The UploadDialog handles bulk upload via the Uploadify jQuery plugin.
dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id        : 'upload_dialog',
  className : 'dialog docalog',

  callbacks : {
    '.ok.click'     : 'confirm',
    '.cancel.click' : 'cancel'
  },

  constructor : function() {
     _.bindAll(this, 'countDocuments', '_onSelect', '_onSelectOnce', '_onCancel',
               '_onStarted', '_onProgress', '_onComplete', '_onAllComplete');
    this.base({
      set       : UploadDocuments,
      mode      : 'custom',
      title     : 'Upload Documents',
      saveText  : 'Upload'
    });
    this.set.bind(dc.Set.MODEL_ADDED, this.countDocuments);
    this.set.bind(dc.Set.MODEL_REMOVED, this.countDocuments);
  },

  render : function() {
    this._tiles = {};
    this._project = _.first(Projects.selected());
    var data = {};
    if (this._project) data.information = 'Project: ' + this._project.get('title');
    this.base(data);
    $('.custom', this.el).html(JST['document/upload_dialog']({}));
    $('.cancel', this.el).text('Cancel');
    this._renderDocumentTiles();
    this.countDocuments();
    this.center();
    return this;
  },

  _renderDocumentTiles : function() {
    var tiles = this._tiles;
    _.each(this.set.models(), function(model) {
      var view = new dc.ui.UploadDocumentTile({model : model});
      tiles[model.id] = view.render();
    });
    var viewEls = _.pluck(_.values(tiles), 'el');
    $('.upload_document_tiles', this.el).append(viewEls);
  },

  setupUploadify : function(uploadify) {
    this._uploadify = uploadify || $('#new_document');
    this._uploadify.uploadify({
      uploader      : '/flash/uploadify.swf',
      script        : '/import/upload_document',
      auto          : false,
      multi         : true,
      wmode         : 'transparent',
      fileDataName  : 'file',
      hideButton    : true,
      width         : this._uploadify.outerWidth(true),
      height        : this._uploadify.outerHeight(true),
      scriptData    : {},
      onSelect      : this._onSelect,
      onSelectOnce  : this._onSelectOnce,
      onCancel      : this._onCancel,
      onStarted     : this._onStarted,
      onProgress    : this._onProgress,
      onComplete    : this._onComplete,
      onAllComplete : this._onAllComplete
    });
  },

  // Return false so that Uploadify does not create its own progress bars.
  _onSelect : function(e, queueId, fileObj) {
    this.set.add(new dc.model.UploadDocument({
      id        : queueId,
      file      : fileObj,
      position  : this.set.size()
    }));
    return false;
  },

  _onSelectOnce : function(e, data) {
    this.render();
  },

  // Cancel an upload by file queue id.
  cancelUpload : function(id) {
    if (this.set.size() <= 1) {
      this.error('You must upload at least one document.');
      return false;
    }
    this._uploadify.uploadifyCancel(id);
    return true;
  },

  // Return false so that Uploadify does not try to use its own progress bars.
  _onCancel : function(e, queueId, fileObj, data) {
    return false;
  },

  _onStarted : function(e, queueId) {
    var attrs = this._tiles[queueId].serialize();
    this.set.get(queueId).set(attrs);
    attrs.session_key = dc.app.cookies.get('document_cloud_session');
    if (this._project) attrs.project_id = this._project.id;
    this._uploadify.uploadifySettings('scriptData', attrs);
    this.showSpinner();
  },

  // Return false so Uploadify doesn't try to update missing fields (from onSelect).
  _onProgress : function(e, queueId, fileObj, data) {
    this._tiles[queueId].setProgress(data.percentage);
    return false;
  },

  _onComplete : function(e, queueId, fileObj, response, data) {
    response = JSON.parse(response);
    if (response.bad_request) {
      return this.error("Upload failed.");
    } else {
      var doc = new top.dc.model.Document(response['document']);
      Documents.add(doc);
      if (this._project) Projects.incrementCountById(this._project.id);
    }
    this._tiles[queueId].hide();
  },

  _onAllComplete : function(e, data) {
    this.hideSpinner();
    this.close();
  },

  countDocuments : function() {
    var num = this.set.size();
    this.title('Upload ' + (num > 1 ? num : '') + Inflector.pluralize(' Document', num));
  },

  confirm : function() {
    var failed = _.select(this._tiles, function(tile) { return tile.ensureTitle(); });
    if (failed.length) {
      var num = this.set.size();
      return this.error('Please enter a title for ' + (num == 1 ? 'the document.' : 'all documents.'));
    }
    $('.ok', this.el).text('Uploading...').setMode('not', 'enabled');
    this._uploadify.uploadifyUpload();
  },

  cancel : function() {
    this._uploadify.uploadifyClearQueue();
    this.close();
  },

  close : function() {
    this.set.refresh();
    this.base();
  }

});

dc.ui.UploadDocumentTile = dc.View.extend({

  className : 'row draggable',

  callbacks : {
    '.remove_queue.click' : 'removeUploadFile',
    '.open_edit.click'    : 'openEdit'
  },

  render : function() {
    $(this.el).html(JST['document/upload_document_tile']({model : this.model}));
    this._title    = $('input[name=title]', this.el);
    this._progress = $('.upload_progress_bar_container', this.el);
    this.setCallbacks();
    return this;
  },

  serialize : function() {
    return {
      title: this._title.val(),
      description: $('textarea[name=description]', this.el).val(),
      source: $('input[name=source]', this.el).val(),
      access: $('select[name=access]', this.el).val()
    };
  },

  removeUploadFile : function() {
    if (dc.app.uploader.cancelUpload(this.model.id)) {
      this.hide();
      UploadDocuments.remove(this.model);
    }
  },

  openEdit : function() {
    $('.upload_edit', this.el).toggle();
    $('.open_edit', this.el).toggleClass('active');
  },

  setProgress : function(percentage) {
    this._progress.animate({width: percentage + '%'}, {queue: false, duration: 150});
  },

  ensureTitle : function() {
    var noTitle = Inflector.trim(this._title.val()) == '';
    this._title.closest('.text_input').toggleClass('error', noTitle);
    return noTitle;
  },

  hide : function() {
    $(this.el).animate({opacity: 0}, 200).slideUp(200, function(){ $(this).remove(); });
  }

});
