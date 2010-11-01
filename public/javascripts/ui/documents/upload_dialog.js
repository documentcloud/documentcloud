// The UploadDialog handles bulk upload via the Uploadify jQuery plugin.
dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id        : 'upload_dialog',
  className : 'dialog',

  INSERT_PAGES_MESSAGE: 'This process will take a few minutes.<br /><br />\
    This window must close while pages are being added and the document is being reconstructed.',

  constructor : function(options) {
    var defaults = {
      editable    : true,
      insertPages : false,
      autoStart   : false,
      collection  : UploadDocuments,
      mode        : 'custom',
      title       : 'Upload Documents',
      saveText    : 'Upload',
      closeText   : 'Cancel'
    };
    options = $.extend({}, defaults, options);

    _.bindAll(this, 'setupUploadify', 'countDocuments', '_onSelect', '_onSelectOnce',
      '_onCancel', '_onStarted', '_onOpen', '_onProgress', '_onComplete', '_onAllComplete');
    dc.ui.Dialog.call(this, options);
    if (dc.app.navigation) {
      dc.app.navigation.bind('tab:documents', _.bind(function(){ _.defer(this.setupUploadify); }, this));
    }
    this.collection.bind('add',   this.countDocuments);
    this.collection.bind('remove', this.countDocuments);
  },

  render : function() {
    this._tiles = {};
    this._project = _.first(Projects.selected());
    var data = {};
    if (this._project) {
      var title = Inflector.truncate(this._project.get('title'), 35);
      data.information = 'Project: ' + title;
    }
    dc.ui.Dialog.prototype.render.call(this, data);
    this.$('.custom').html(JST['document/upload_dialog']());
    this._list = this.$('.upload_list');
    this._renderDocumentTiles();
    this.countDocuments();
    this.center();
    if (this.options.autoStart) {
      this.$('.controls').hide();
    }
    if (this.options.insertPages) {
      this.title($('.replace_pages_hint').text());
    } else {
      this.checkQueueLength();
    }
    return this;
  },

  _renderDocumentTiles : function() {
    var tiles = this._tiles;
    var editable = this.options.editable;

    this.collection.each(function(model) {
      var view = new dc.ui.UploadDocumentTile({
        editable : editable,
        model : model
      });
      tiles[model.id] = view.render();
    });

    var viewEls = _.pluck(_.values(tiles), 'el');
    this._list.append(viewEls);
  },

  // Be careful to only set up Uploadify once, when the "Documents" tab is open.
  setupUploadify : function() {
    if (this._uploadify || (dc.app.navigation && !dc.app.navigation.isOpen('documents'))) return;
    var uploadUrl = '/import/upload_document';
    if (this.options.insertPages) {
      uploadUrl = '/documents/' + this.options.documentId + '/upload_insert_document';
    }
    this._uploadify = $('#new_document');
    this._uploadify.uploadify({
      uploader      : '/flash/uploadify.swf',
      script        : uploadUrl,
      auto          : false,
      multi         : true,
      wmode         : 'transparent',
      fileDataName  : 'file',
      hideButton    : true,
      width         : this.button.outerWidth(true),
      height        : this.button.outerHeight(true),
      scriptData    : {},
      onSelect      : _.bind(this._onSelect, this),
      onSelectOnce  : this._onSelectOnce,
      onCancel      : this._onCancel,
      onStarted     : this._onStarted,
      onOpen        : this._onOpen,
      onProgress    : this._onProgress,
      onComplete    : this._onComplete,
      onAllComplete : this._onAllComplete
    });
    this._uploadIndex = 0;
  },

  // Return false so that Uploadify does not create its own progress bars.
  _onSelect : function(e, queueId, fileObj) {
    this.collection.add(new dc.model.UploadDocument({
      id        : queueId,
      file      : fileObj,
      position  : this.collection.length
    }));
    return false;
  },

  _onSelectOnce : function(e, data) {
    if (this.collection.any(function(file){ return file.overSizeLimit(); })) {
      this.close();
      return dc.ui.Dialog.alert("You can only upload documents less than 200MB in size. Please <a href=\"/help/troubleshooting\">optimize your document</a> before continuing.");
    }
    this.render();
    if (this.options.autostart) {
      this._uploadify.uploadifyUpload();
    }
  },

  // Cancel an upload by file queue id.
  cancelUpload : function(id) {
    if (this.collection.length <= 1) {
      this.error('You must upload at least one document.');
      return false;
    }
    this.button.uploadifyCancel(id);
    return true;
  },

  // Return false so that Uploadify does not try to use its own progress bars.
  _onCancel : function(e, queueId, fileObj, data) {
    return false;
  },

  // Called immediately before file to POSTed to server.
  _onStarted : function(e, queueId) {
    this._uploadIndex++;
    var attrs = this._tiles[queueId].serialize();
    this.collection.get(queueId).set(attrs);
    attrs.session_key = dc.app.cookies.get('document_cloud_session');
    attrs.flash = true;
    if (this._project) attrs.project_id = this._project.id;
    if (_.isNumber(this.options.insertPageAt)) attrs.insert_page_at = this.options.insertPageAt;
    if (_.isNumber(this.options.replacePagesStart)) attrs.replace_pages_start = this.options.replacePagesStart;
    if (_.isNumber(this.options.replacePagesEnd)) attrs.replace_pages_end = this.options.replacePagesEnd;
    if (this.options.documentId)   attrs.document_id = this.options.documentId;
    if (this.options.insertPages)  attrs.document_number = this._uploadIndex;
    if (this.options.insertPages)  attrs.document_count = this.collection.length;
    this._uploadify.uploadifySettings('scriptData', attrs, true);
    this.showSpinner();
    this._list[0].scrollTop = 0;
  },

  // Show the progress bar when the uploads start.
  _onOpen : function(e, queueId, fileObj) {
    this._tiles[queueId].startProgress();
  },

  // Return false so Uploadify doesn't try to update missing fields (from onSelect).
  _onProgress : function(e, queueId, fileObj, data) {
    this._tiles[queueId].setProgress(data.percentage);
    return false;
  },

  _onComplete : function(e, queueId, fileObj, resp, data) {
    resp = JSON.parse(resp);
    if (resp.bad_request) {
      return this.error("Upload failed.");
    } else if (!this.options.insertPages) {
      Documents.add(new dc.model.Document(response.model));
      if (this._project) Projects.incrementCountById(this._project.id);
    } else if (this.options.insertPages) {
      this.documentResponse = response;
    }
    this._tiles[queueId].hide();
  },

  _onAllComplete : function(e, data) {
    this.hideSpinner();
    if (this.options.insertPages) {
      try {
        window.opener && window.opener.Documents &&
          window.opener.Documents.get(this.options.documentId).set(this.documentResponse);
      } catch (e) {
        // No parent window...
      }
      dc.ui.Dialog.alert(this.INSERT_PAGES_MESSAGE, {onClose : window.close});
    }
    this.close();
  },

  countDocuments : function() {
    var num = this.collection.length;
    this.title('Upload ' + (num > 1 ? num : '') + Inflector.pluralize(' Document', num));
    this.$('.upload_email_count').text(num == 1 ? 'this document has' : 'these documents have');
  },

  checkQueueLength : function() {
    $.getJSON('/documents/queue_length.json', {}, _.bind(function(resp) {
      var num = resp.queue_length;
      if (num <= 0) return;
      var conj = num > 1 ? 'are' : 'is';
      this.info('There ' + conj + ' ' + num + ' ' + Inflector.pluralize('document', num) + ' ahead of you in line.', true);
    }, this));
  },

  insertPagesAttrs : function(attrs) {
    _.each(attrs, _.bind(function(value, attr) {
      this.options[attr] = value;
    }, this));
  },

  confirm : function() {
    var failed = _.select(this._tiles, function(tile) { return tile.ensureTitle(); });
    if (failed.length) {
      var num = this.collection.length;
      return this.error('Please enter a title for ' + (num == 1 ? 'the document.' : 'all documents.'));
    }
    this.$('.ok').setMode('not', 'enabled');
    this.button.uploadifyUpload();
  },

  cancel : function() {
    this.button.uploadifyClearQueue();
    this.close();
  },

  close : function() {
    this.collection.refresh();
    dc.ui.Dialog.prototype.close.call(this);
  }

});

dc.ui.UploadDocumentTile = Backbone.View.extend({

  className : 'row',

  events : {
    'click .remove_queue' : 'removeUploadFile',
    'click .open_edit'    : 'openEdit',
    'click .apply_all'    : 'applyAll'
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
  },

  render : function() {
    var template = JST['document/upload_document_tile']({
      editable : this.options.editable,
      model : this.model
    });
    $(this.el).html(template);
    this._title    = this.$('input[name=title]');
    this._progress = this.$('.progress_bar');
    return this;
  },

  serialize : function() {
    return {
      title       : this._title.val(),
      description : this.$('textarea[name=description]').val(),
      source      : this.$('input[name=source]').val(),
      access      : this.$('select[name=access]').val()
    };
  },

  removeUploadFile : function() {
    if (dc.app.uploader.cancelUpload(this.model.id)) {
      this.hide();
      UploadDocuments.remove(this.model);
    }
  },

  // Apply the current file's attributes to all files in the upload.
  applyAll : function() {
    var dialog = dc.app.uploader.el;
    var attrs  = this.serialize();
    $('textarea[name=description]', dialog).val(attrs.description);
    $('input[name=source]',         dialog).val(attrs.source);
    $('select[name=access]',        dialog).val(attrs.access);
    dc.app.uploader.info('Update applied to all files.');
  },

  openEdit : function() {
    this.$('.upload_edit').toggle();
    this.$('.open_edit').toggleClass('active');
  },

  startProgress : function() {
    this._percentage = 0;
    this._progress.show();
  },

  setProgress : function(percentage) {
    if (percentage <= this._percentage) return;
    this._percentage = percentage;
    this._progress.stop(true).css({width: percentage + '%'}, {queue: false, duration: 150});
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
