// A tile view for previewing a Document in a listing.
dc.ui.Document = dc.View.extend({

  className : 'document',

  callbacks : {
    '.view_document.click': 'viewDocument',
    // ['.view_pdf',         'click',  'viewPDF'],
    // ['.view_text',        'click',  'viewFullText'],
    // ['.download_viewer',  'click',  'downloadViewer'],
    // ['.delete_document',  'click',  'deleteDocument'],
    '.icon.click':  'select'
  },

  constructor : function(doc, mode) {
    this.mode = mode;
    if (mode) this.className += ' ' + mode;
    this.base({model : doc});
    this.el.id = 'document_' + this.model.id;
    _.bindAll(this, '_onDocumentChange', '_onDrop');
    this.model.bind(dc.Model.CHANGED, this._onDocumentChange);
  },

  render : function() {
    var title = this.model.get('title');
    $(this.el).html(JST.document_tile({
      thumbnail : this.model.get('thumbnail_url'),
      title     : this.mode == 'viz' ? Inflector.truncate(title, 55) : title,
      source    : this.model.get('source'),
      summary   : this.model.displaySummary(),
      pub       : this.model.get('access') == dc.access.PUBLIC
    }));
    $('.document.icon', this.el).draggable({ghost : true, onDrop : this._onDrop});
    this.setCallbacks();
    this._setSelected();
    return this;
  },

  select : function() {
    if (!dc.app.accountId) return;
    var selected = !this.model.get('selected');
    this.model.set({selected : selected});
  },

  viewDocument : function() {
    window.open(this.model.get('document_viewer_url'));
  },

  viewPDF : function() {
    window.open(this.model.get('pdf_url'));
  },

  viewFullText : function() {
    window.open(this.model.get('full_text_url'));
  },

  downloadViewer : function() {
    this.model.downloadViewer();
  },

  deleteDocument : function(e) {
    e.preventDefault();
    var destructor = _.bind(Documents.destroy, Documents, this.model);
    dc.ui.Dialog.confirm('Really delete "' + this.model.get('title') + '" ?', destructor);
  },

  _setSelected : function() {
    this.setMode(this.model.get('selected') ? 'is' : 'not', 'selected');
  },

  _onDocumentChange : function() {
    var changed = this.model.hasChanged('summary') || this.model.hasChanged('access');
    changed ? this.render() : this._setSelected();
  },

  // When the document is dropped onto a project, add it to the project.
  _onDrop : function(e) {
    var doc = this.model;
    var x = e.pageX, y = e.pageY;
    $('#organizer .project').each(function() {
      var top = $(this).offset().top, left = $(this).offset().left;
      var right = left + $(this).outerWidth(), bottom = top + $(this).outerHeight();
      if (left < x && right > x && top < y && bottom > y) {
        var project = Projects.getByCid($(this).attr('data-project-cid'));
        project.addDocuments([doc]);
        return false;
      }
    });
  }

});