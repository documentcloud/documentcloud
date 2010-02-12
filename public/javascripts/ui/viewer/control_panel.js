dc.ui.ViewerControlPanel = dc.View.extend({

  id : 'control_panel',

  callbacks : {
    '.set_sections.click':        'openSectionEditor',
    '.public_annotation.click':   'togglePublicAnnotation',
    '.private_annotation.click':  'togglePrivateAnnotation',
    '.edit_description.click':    'editDescription',
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

  editDescription : function() {
    dc.ui.Dialog.prompt('Description', DV.api.getDescription(), function(desc) {
      DV.api.setDescription(desc);
      var id = parseInt(DV.Schema.document.id, 10);
      var doc = new dc.model.Document({id : id, description : desc});
      Documents.update(doc);
      try {
        var doc = window.opener && window.opener.Documents && window.opener.Documents.get(doc);
        if (doc) doc.set({description : desc});
      } catch (e) {
        // Couldn't access the parent window -- it's ok.
      }
      return true;
    });
  },

  togglePublicAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('public');
  },

  togglePrivateAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('private');
  },

  savePageText : function() {
    var url = '/documents/' + dc.app.editor.docId + '/pages/' + DV.Schema.document.id + '-p' + DV.api.currentPage() + '.txt';
    var text = this._page.textWithNewlines();
    $.ajax({url : url, type : 'POST', data : {text : text}, dataType : 'json'});
    dc.app.editor.notify({mode : 'info', text : 'page saved'});
  }

});