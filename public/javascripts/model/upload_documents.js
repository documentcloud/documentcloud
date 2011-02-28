// An UploadDocument is an in-progress file upload, currently waiting in the queue.
dc.model.UploadDocument = Backbone.Model.extend({

  FILE_EXTENSION_MATCHER : /\.([^.]+)$/,

  MAX_FILE_SIZE : 209715200, // 200 Megabytes

  // When creating an UploadDocument, we pull off some properties that
  // Uploadify provides on the file object, and attach them as attributes.
  set : function(attrs) {
    var file = attrs.file;
    if (file) {
      delete attrs.file;
      var fileName    = file.fileName || file.name;
      fileName        = fileName.match(/[^\/\\]+$/)[0]; // C:\fakepath\yatta yatta.pdf => yatta yatta.pdf
      attrs.title     = Inflector.titleize(fileName.replace(this.FILE_EXTENSION_MATCHER, ''));
      var match       = fileName.match(this.FILE_EXTENSION_MATCHER);
      attrs.extension = match && match[1];
      attrs.size      = file.fileSize || null;
    }
    Backbone.Model.prototype.set.call(this, attrs);
  },

  overSizeLimit : function() {
    return this.get('size') >= this.MAX_FILE_SIZE;
  }

});

// The set of UploadDocuments is ordered by the position in which they were added.
dc.model.UploadDocumentSet = Backbone.Collection.extend({

  model : dc.model.UploadDocument,

  comparator : function(model) {
    return model.get('position');
  }

});

window.UploadDocuments = new dc.model.UploadDocumentSet();