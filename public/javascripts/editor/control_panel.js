dc.ui.ViewerControlPanel = Backbone.View.extend({

  id : 'control_panel',

  events : {
    'click .set_sections':          'openSectionEditor',
    'click .public_annotation':     'togglePublicAnnotation',
    'click .private_annotation':    'togglePrivateAnnotation',
    'click .edit_description':      'editDescription',
    'click .edit_title':            'editTitle',
    'click .edit_related_article':  'editRelatedArticle',
    'click .edit_document_url':     'editPublishedUrl',
    'click .edit_remove_pages':     'editRemovePages',
    'click .edit_reorder_pages':    'editReorderPages',
    'click .edit_page_text':        'editPageText',
    'click .reprocess_text':        'reprocessText',
    'click .edit_replace_pages':    'editReplacePages'
  },

  render : function() {
    this._page = currentDocument.$('.DV-textContents');
    $(this.el).html(JST['control_panel']({isOwner : dc.app.editor.isOwner}));
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
    }, this), {
      mode : 'short_prompt',
      description : 'Enter the URL of the article that references this document:'
    });
  },

  editPublishedUrl : function() {
    dc.ui.Dialog.prompt('Published URL', currentDocument.api.getPublishedUrl(), _.bind(function(url, dialog) {
      url = Inflector.normalizeUrl(url);
      if (url && !dialog.validateUrl(url)) return false;
      currentDocument.api.setPublishedUrl(url);
      this._updateDocument({remote_url : url});
      return true;
    }, this), {
      mode        : 'short_prompt',
      description : 'Enter the URL of the page on which this document is embedded:'
    });
  },

  editDescription : function() {
    dc.ui.Dialog.prompt('Description', currentDocument.api.getDescription(), _.bind(function(desc) {
      currentDocument.api.setDescription(desc);
      this._updateDocument({description : desc});
      return true;
    }, this));
  },

  reprocessText : function() {
    var finish = _.bind(function(force) {
      var doc = this._getDocument();
      doc.reprocessText(force);
      this._setOnParent(doc, {access: dc.access.PENDING});
    }, this);
    var dialog = new dc.ui.Dialog.confirm("This will reprocess the text from the original document. You may also force the text to be extracted by optical character recognition.<br /><br />While the text is being reprocessed, this window will close.", function() {
      finish();
      window.close();
    });
    var force = $(dialog.make('div', {'class':'minibutton dark'}, 'Force OCR')).bind('click', function() {
      finish(true);
      window.close();
    });
    dialog.$('.ok').text('Reprocess').before(force);
  },

  editPageText : function() {
    dc.app.editor.pageTextEditor.toggle();
  },

  editReplacePages : function() {
    dc.app.editor.replacePagesEditor.toggle();
  },

  editRemovePages : function() {
    dc.app.editor.removePagesEditor.toggle();
  },

  editReorderPages : function() {
    dc.app.editor.reorderPagesEditor.toggle();
  },

  togglePublicAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('public');
  },

  togglePrivateAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('private');
  },

  _getDocument : function(attrs) {
    attrs || (attrs = {});
    attrs.id = parseInt(currentDocument.api.getId(), 10);
    return new dc.model.Document(_.clone(attrs));
  },

  _setOnParent : function(doc, attrs) {
    try {
      var doc = window.opener && window.opener.Documents && window.opener.Documents.get(doc);
      if (doc) doc.set(attrs);
    } catch (e) {
      // Couldn't access the parent window -- it's ok.
    }
  },

  _updateDocument : function(attrs) {
    var doc = this._getDocument(attrs);
    doc.save();
    this._setOnParent(doc, attrs);
  }

});