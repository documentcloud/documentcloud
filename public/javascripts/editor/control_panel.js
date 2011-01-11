dc.ui.ViewerControlPanel = Backbone.View.extend({

  id : 'control_panel',

  events : {
    'click .set_sections':          'openSectionEditor',
    'click .public_annotation':     'togglePublicAnnotation',
    'click .private_annotation':    'togglePrivateAnnotation',
    'click .edit_description':      'editDescription',
    'click .edit_title':            'editTitle',
    'click .edit_source':           'editSource',
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
    var accessWorkspace = _.contains(dc.model.Account.COLLABORATOR_ROLES, dc.app.editor.accountRole);
    $(this.el).html(JST['control_panel']({
      isReviewer      : dc.app.editor.options.isReviewer,
      isOwner         : dc.app.editor.options.isOwner,
      workspacePrefix : accessWorkspace ? '#' : ''
    }));
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

  editSource : function() {
    dc.ui.Dialog.prompt('Source', currentDocument.api.getSource(), _.bind(function(source) {
      currentDocument.api.setSource(source);
      this._updateDocument({source : source});
      return true;
    }, this), {mode: 'short_prompt'});
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
    var closeMessage = "The text is being processed. Please close this document.";
    var dialog = new dc.ui.Dialog.confirm("Reprocess this document to take \
        advantage of improvements to our text extraction tools. Choose \
        \"Force OCR\" (optical character recognition) to ignore any embedded \
        text information and use Tesseract before reprocessing. The document will \
        close while it's being rebuilt. Are you sure you want to proceed? ", function() {
      finish();
      window.close();
      _.defer(dc.ui.Dialog.alert, closeMessage);
    }, {width: 450});
    var force = $(dialog.make('div', {'class':'minibutton dark'}, 'Force OCR')).bind('click', function() {
      finish(true);
      window.close();
      _.defer(dc.ui.Dialog.alert, closeMessage);
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