dc.ui.ViewerControlPanel = dc.View.extend({

  id : 'control_panel',

  callbacks : {
    '.set_sections.click':        'openSectionEditor',
    '.public_annotation.click':   'togglePublicAnnotation',
    '.private_annotation.click':  'togglePrivateAnnotation',
    '.edit_description.click':    'editDescription',
    '.edit_title.click':          'editTitle',
    '.save_text.click':           'savePageText'
  },

  render : function() {
    this._page = $('#DV-textContents');
    $(this.el).html(JST.viewer_control_panel({isOwner : dc.app.editor.isOwner}));
    this.setCallbacks();
    return this;
  },

  openSectionEditor : function() {
    dc.app.editor.sectionEditor.open();
  },

  editTitle : function() {
    dc.ui.Dialog.prompt('Title', DV.api.getTitle(), _.bind(function(title) {
      DV.api.setTitle(title);
      this._updateDocument({title : title});
      return true;
    }, this), true);
  },

  editDescription : function() {
    dc.ui.Dialog.prompt('Description', DV.api.getDescription(), _.bind(function(desc) {
      DV.api.setDescription(desc);
      this._updateDocument({description : desc});
      return true;
    }, this));
  },

  togglePublicAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('public');
  },

  togglePrivateAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('private');
  },

  savePageText : function() {
    var page = DV.api.currentPage();
    var url  = '/documents/' + dc.app.editor.docId + '/pages/' + DV.Schema.document.id + '-p' + page + '.txt';
    var text = this._page.textWithNewlines();
    DV.api.setPageText(text, page);
    $.ajax({url : url, type : 'POST', data : {text : text}, dataType : 'json'});
    dc.app.editor.notify({mode : 'info', text : 'page saved'});
  },

  _updateDocument : function(attrs) {
    attrs.id = parseInt(DV.Schema.document.id, 10);
    var doc = new dc.model.Document(attrs);
    Documents.update(doc);
    try {
      var doc = window.opener && window.opener.Documents && window.opener.Documents.get(doc);
      if (doc) doc.set(attrs);
    } catch (e) {
      // Couldn't access the parent window -- it's ok.
    }
  }

});