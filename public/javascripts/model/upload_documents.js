// An UploadDocument is an in-progress file upload, currently waiting in the queue.
dc.model.UploadDocument = Backbone.Model.extend({

  FILE_EXTENSION_MATCHER : /\.([^.]+)$/,

  MAX_FILE_SIZE : 419430400, // 400 Megabytes

  // When creating an UploadDocument, we pull off some properties that
  // are on the file object, and attach them as attributes.
  set : function(attrs) {
    var file = attrs.file;
    if (file) {
      delete attrs.file;
      var fileName    = file.fileName || file.name;
      fileName        = fileName.match(/[^\/\\]+$/)[0]; // C:\fakepath\yatta yatta.pdf => yatta yatta.pdf
      attrs.title     = dc.inflector.titleize(fileName.replace(this.FILE_EXTENSION_MATCHER, ''));
      var extMatch    = fileName.match(this.FILE_EXTENSION_MATCHER);
      attrs.extension = extMatch && extMatch[1];
      attrs.size      = file.fileSize || file.size || null;
    }
    Backbone.Model.prototype.set.call(this, attrs);
    return this;
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