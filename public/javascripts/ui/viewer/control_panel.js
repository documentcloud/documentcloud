dc.ui.ViewerControlPanel = Backbone.View.extend({

  id : 'control_panel',

  callbacks : {
    '.set_sections.click':          'openSectionEditor',
    '.public_annotation.click':     'togglePublicAnnotation',
    '.private_annotation.click':    'togglePrivateAnnotation',
    '.edit_description.click':      'editDescription',
    '.edit_title.click':            'editTitle',
    '.edit_related_article.click':  'editRelatedArticle',
    '.edit_remove_pages.click':     'editRemovePages',
    '.edit_reorder_pages.click':    'editReorderPages',
    '.edit_page_text.click':        'editPageText'
  },

  render : function() {
    this._page = currentDocument.$('.DV-textContents');
    $(this.el).html(JST['viewer/control_panel']({isOwner : dc.app.editor.isOwner}));
    var contributor = currentDocument.api.getContributor();
    var org = currentDocument.api.getContributorOrganization();
    if (contributor && org) {
      currentDocument.$('.DV-contributor').text("Contributed by: " + contributor + ', ' + org);
    }
    return this;
  },

  openSectionEditor : function() {
    dc.app.editor.sectionEditor.open();
  },

  editTitle : function() {
    dc.ui.Dialog.prompt('Title', currentDocument.api.getTitle(), _.bind(function(title) {
      currentDocument.api.setTitle(title);
      this._updateDocument({title : title});
      return true;
    }, this), {mode : 'short_prompt'});
  },

  editRelatedArticle : function() {
    dc.ui.Dialog.prompt('Related Article URL', currentDocument.api.getRelatedArticle(), _.bind(function(url, dialog) {
      url = Inflector.normalizeUrl(url);
      if (url && !dialog.validateUrl(url)) return false;
      currentDocument.api.setRelatedArticle(url);
      this._updateDocument({related_article : url});
      return true;
    }, this), {mode : 'short_prompt'});
  },

  editDescription : function() {
    dc.ui.Dialog.prompt('Description', currentDocument.api.getDescription(), _.bind(function(desc) {
      currentDocument.api.setDescription(desc);
      this._updateDocument({description : desc});
      return true;
    }, this));
  },
  
  editPageText : function() {
    var pageNumber = currentDocument.api.currentPage();
    dc.ui.Dialog.prompt('Page Text', currentDocument.api.getPageText(pageNumber), _.bind(function(pageText) {
      currentDocument.api.setPageText(pageText);
      currentDocument.api.redraw();
      return true;
    }, this));
  },
  
  editRemovePages : function() {
    dc.app.editor.removePagesEditor.toggle();
  },

  togglePublicAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('public');
  },

  togglePrivateAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('private');
  },

  _updateDocument : function(attrs) {
    attrs.id = parseInt(currentDocument.api.getId(), 10);
    var doc = new dc.model.Document(attrs);
    doc.save();
    try {
      var doc = window.opener && window.opener.Documents && window.opener.Documents.get(doc);
      if (doc) doc.set(attrs);
    } catch (e) {
      // Couldn't access the parent window -- it's ok.
    }
  }

});