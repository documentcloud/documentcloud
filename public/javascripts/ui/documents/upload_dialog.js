// The UploadDialog handles bulk upload via the Uploadify jQuery plugin.
dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id        : 'upload_dialog',
  className : 'dialog',

  INSERT_PAGES_MESSAGE: "This document will close while it's being rebuilt. Long documents may take a long time to rebuild.",

  constructor : function(options) {
    var defaults = {
      editable        : true,
      insertPages     : false,
      autoStart       : false,
      collection      : UploadDocuments,
      mode            : 'custom',
      title           : 'Upload Documents',
      saveText        : 'Upload',
      closeText       : 'Cancel',
      multiFileUpload : false
    };
    options = _.extend({}, defaults, options);

    _.bindAll(this, 'setupUpload', 'countDocuments', 'cancelUpload',
      '_onSelect', '_onProgress', '_onComplete', '_onAllComplete');
    dc.ui.Dialog.call(this, options);
    if (options.autoStart) $(this.el).addClass('autostart');
    if (dc.app.navigation) {
      dc.app.navigation.bind('tab:documents', _.bind(function(){ _.defer(this.setupUpload); }, this));
    }
    this.collection.bind('add',   this.countDocuments);
    this.collection.bind('remove', this.countDocuments);
  },

  render : function() {
    this.options.multiFileUpload = window.FileList && ($("input[type=file]")[0].files instanceof FileList);
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
    if (!this.options.autostart) this.checkQueueLength();
    return this;
  },

  _renderDocumentTiles : function() {
    var tiles           = this._tiles;
    var editable        = this.options.editable;
    var multiFileUpload = this.options.multiFileUpload;

    this.collection.each(function(model) {
      var view = new dc.ui.UploadDocumentTile({
        editable        : editable,
        model           : model,
        multiFileUpload : multiFileUpload
      });
      tiles[model.id] = view.render();
    });

    var viewEls = _.pluck(_.values(tiles), 'el');
    this._list.append(viewEls);
  },

  // Be careful to only setup file uploading once, when the "Documents" tab is open.
  setupUpload : function() {
    if (this.form || (dc.app.navigation && !dc.app.navigation.isOpen('documents'))) return;
    var uploadUrl = '/import/upload_document';
    if (this.options.insertPages) {
      uploadUrl = '/documents/' + this.options.documentId + '/upload_insert_document';
    }
    this.form = $('#new_document_form');
    this.form.fileUpload({
        url        : uploadUrl,
        onAbort    : this.cancelUpload,
        initUpload : this._onSelect,
        onProgress : this._onProgress,
        onLoad     : this._onComplete
    });
  },

  // If flash is disabled, we fall back to a regular invisible file input field.
  setupFileInput : function() {
    var input = $('#new_document_input');
    input.show().change(_.bind(function() {
      this._project = _.first(Projects.selected());
      $('#new_document_project').val(this._project ? this._project.id : '');
      $('#new_document_form').submit();
    }, this));
  },

  // Initial load of a document, before uploading is begun.
  _onSelect : function(e, files, index, xhr, handler, callback) {
    var file = files[index];
    this.collection.add(new dc.model.UploadDocument({
      id          : Inflector.sluggify(file.fileName || file.name),
      uploadIndex : index,
      file        : file,
      position    : index,
      handler     : handler,
      startUpload : callback
    }));

    if (index != files.length - 1) return;

    if (this.collection.any(function(file){ return file.overSizeLimit(); })) {
      this.close();
      return dc.ui.Dialog.alert("You can only upload documents less than 200MB in size. Please <a href=\"/help/troubleshooting\">optimize your document</a> before continuing.");
    }

    this.render();
    if (this.options.autoStart) this.startUpload(index);
  },

  // Cancel an upload by index.
  cancelUpload : function(uploadIndex) {
    if (this.collection.length <= 1) {
      this.error('You must upload at least one document.');
      return false;
    }
    return true;
  },

  // Called immediately before file to POSTed to server.
  _uploadData : function(id, index) {
    var attrs = this._tiles[id].serialize();
    this.collection.get(id).set(attrs);
    if (this.options.multiFileUpload) attrs.multi_file_upload = true;
    attrs.authenticity_token = $("meta[name='csrf-token']").attr("content");
    attrs.email_me = this.$('.upload_email input').is(':checked') ? this.collection.length : 0;
    if (this._project) attrs.project = this._project.id;
    if (_.isNumber(this.options.insertPageAt)) attrs.insert_page_at = this.options.insertPageAt;
    if (_.isNumber(this.options.replacePagesStart)) attrs.replace_pages_start = this.options.replacePagesStart;
    if (_.isNumber(this.options.replacePagesEnd)) attrs.replace_pages_end = this.options.replacePagesEnd;
    if (this.options.documentId)  attrs.document_id     = this.options.documentId;
    if (this.options.insertPages) attrs.document_number = index + 1;
    if (this.options.insertPages) attrs.document_count  = this.collection.length;
    if (!this.options.autoStart) this.showSpinner();
    this._list[0].scrollTop = 0;
    return attrs;
  },

  // Return false so Uploadify doesn't try to update missing fields (from onSelect).
  _onProgress : function(e, files, index, xhr, handler) {
    var id         = Inflector.sluggify(files[index].fileName || files[index].name);
    var percentage = parseInt((e.loaded / e.total) * 100, 10);

    this._tiles[id].setProgress(percentage);
  },

  _onComplete : function(e, files, index, xhr, handler) {
    var id   = Inflector.sluggify(files[index].fileName || files[index].name);
    var resp = xhr.responseText && JSON.parse(xhr.responseText);

    this._tiles[id].setProgress(100);

    if (resp && resp.bad_request) {
      return this.error("Upload failed.");
    } else if (!this.options.insertPages && resp) {
      Documents.add(new dc.model.Document(resp));
      if (this._project) Projects.incrementCountById(this._project.id);
    } else if (this.options.insertPages && resp) {
      this.documentResponse = resp;
    }

    this._tiles[id].hide();

    this.collection.remove(this.collection.first());

    if (index >= files.length - 1) {
      this._onAllComplete();
    } else {
      this.startUpload(index);
    }
  },

  _onAllComplete : function() {
    this.hideSpinner();
    if (this.options.insertPages) {
      try {
        window.opener && window.opener.Documents &&
          window.opener.Documents.get(this.options.documentId).set(this.documentResponse);
      } catch (e) {
        // No parent window...
      }
      dc.ui.Dialog.alert(this.INSERT_PAGES_MESSAGE, {onClose : function() {
        window.close();
        _.defer(dc.ui.Dialog.alert, "The pages are being processed. Please close this document.");
      }});
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
    this.startUpload(0);
  },

  startUpload : function(index) {
    var tiles = this._tiles;
    var doc = this.collection.first();
    doc.get('handler').formData = this._uploadData(doc.get('id'), index);
    doc.get('startUpload')();
    tiles[doc.get('id')].startProgress();
  },

  cancel : function() {
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
      editable        : this.options.editable,
      model           : this.model,
      multiFileUpload : this.options.multiFileUpload
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
    if (dc.app.uploader.cancelUpload(this.model.get('uploadIndex'))) {
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
    if (this.options.multiFileUpload) {
      this._progress.show();
    }
  },

  setProgress : function(percentage) {
    if (percentage <= this._percentage) return;
    this._percentage = percentage;
    this._progress.stop(true).animate({width: percentage + '%'}, {queue: false, duration: 400});
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
