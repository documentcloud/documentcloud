// An UploadDocument is an in-progress file upload, currently waiting in the
// Uploadify queue.
dc.model.UploadDocument = dc.Model.extend({

  FILE_EXTENSION_MATCHER : /\.([^.]+)$/,

  // When creating an UploadDocument, we pull off some properties that
  // Uploadify provides on the file object, and attach them as attributes.
  set : function(attrs) {
    var file = attrs.file;
    if (file) {
      delete attrs.file;
      attrs.name      = file.name.replace(this.FILE_EXTENSION_MATCHER, '');
      var match       = file.name.match(this.FILE_EXTENSION_MATCHER);
      attrs.extension = match && match[1];
      attrs.size      = file.size;
    }
    this.base(attrs);
  }

});

// The set of UploadDocuments is ordered by the position in which they were added.
dc.model.UploadDocumentSet = dc.Set.extend({

  model : dc.model.UploadDocument,

  comparator : function(model) {
    return model.get('position');
  }

});

dc.model.UploadDocumentSet.implement(dc.model.SortedSet);

window.UploadDocuments = new dc.model.UploadDocumentSet();