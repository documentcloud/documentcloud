dc.ui.ViewerControlPanel = Backbone.View.extend({

  id : 'control_panel',

  events : {
    'click .set_sections':          'openSectionEditor',
    'click .public_annotation':     'togglePublicAnnotation',
    'click .private_annotation':    'togglePrivateAnnotation',
    'click .edit_document_info':    'editDocumentInfo',
    'click .edit_description':      'editDescription',
    'click .edit_title':            'editTitle',
    'click .edit_source':           'editSource',
    'click .edit_related_article':  'editRelatedArticle',
    'click .edit_document_url':     'editPublishedUrl',
    'click .edit_remove_pages':     'editRemovePages',
    'click .edit_reorder_pages':    'editReorderPages',
    'click .edit_page_text':        'editPageText',
    'click .reprocess_text':        'reprocessText',
    'click .edit_replace_pages':    'editReplacePages',
    'click .toggle_document_info':  'toggleDocumentInfo'
  },

  render : function() {
    this.viewer = currentDocument;
    this._page = this.viewer.$('.DV-textContents');
    $(this.el).html(JST['control_panel']({isOwner : dc.app.editor.isOwner}));
    var contributor = this.viewer.api.getContributor();
    var org = this.viewer.api.getContributorOrganization();
    if (contributor && org) {
      this.viewer.$('.DV-contributor').text("Contributed by: " + contributor + ', ' + org);
    }
    return this;
  },

  openSectionEditor : function() {
    dc.app.editor.sectionEditor.open();
  },

  editDocumentInfo : function(e) {
    if ($(e.target).is('.toggle_document_info')) return;
    var doc = this._getDocument({}, true);
    new dc.ui.DocumentDialog([doc]);
  },

  editTitle : function() {
    dc.ui.Dialog.prompt('Title', this.viewer.api.getTitle(), _.bind(function(title) {
      this.viewer.api.setTitle(title);
      this._updateDocument({title : title});
      return true;
    }, this), {mode : 'short_prompt'});
  },

  editSource : function() {
    dc.ui.Dialog.prompt('Source', this.viewer.api.getSource(), _.bind(function(source) {
      this.viewer.api.setSource(source);
      this._updateDocument({source : source});
      return true;
    }, this), {mode: 'short_prompt'});
  },

  editRelatedArticle : function() {
    dc.ui.Dialog.prompt('Related Article URL', this.viewer.api.getRelatedArticle(), _.bind(function(url, dialog) {
      url = Inflector.normalizeUrl(url);
      if (url && !dialog.validateUrl(url)) return false;
      this.viewer.api.setRelatedArticle(url);
      this._updateDocument({related_article : url});
      return true;
    }, this), {
      mode : 'short_prompt',
      description : 'Enter the URL of the article that references this document:'
    });
  },

  editPublishedUrl : function() {
    dc.ui.Dialog.prompt('Published URL', this.viewer.api.getPublishedUrl(), _.bind(function(url, dialog) {
      url = Inflector.normalizeUrl(url);
      if (url && !dialog.validateUrl(url)) return false;
      this.viewer.api.setPublishedUrl(url);
      this._updateDocument({remote_url : url});
      return true;
    }, this), {
      mode        : 'short_prompt',
      description : 'Enter the URL of the page on which this document is embedded:'
    });
  },

  editDescription : function() {
    dc.ui.Dialog.prompt('Description', this.viewer.api.getDescription(), _.bind(function(desc) {
      this.viewer.api.setDescription(desc);
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
    var force = $(dialog.make('span', {'class':'minibutton dark center_button'}, 'Force OCR')).bind('click', function() {
      finish(true);
      window.close();
      _.defer(dc.ui.Dialog.alert, closeMessage);
    });
    dialog.$('.ok').text('Reprocess').before(force);
  },

  openTextTab : function() {
    if (this.viewer.state != 'ViewText') {
        this.viewer.open('ViewText');
    }
  },

  openThumbnailsTab : function() {
    if (this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
  },
  
  editPageText : function() {
    this.openTextTab();
    dc.app.editor.editPageTextEditor.toggle();
  },

  editReplacePages : function() {
    this.openThumbnailsTab();
    dc.app.editor.replacePagesEditor.toggle();
  },

  editRemovePages : function() {
    this.openThumbnailsTab();
    dc.app.editor.removePagesEditor.toggle();
  },

  editReorderPages : function() {
    this.openThumbnailsTab();
    dc.app.editor.reorderPagesEditor.toggle();
  },

  togglePublicAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('public');
  },

  togglePrivateAnnotation : function() {
    dc.app.editor.annotationEditor.toggle('private');
  },
  
  toggleDocumentInfo : function() {
    var showing = $('.edit_document_fields').is(':visible');
    $('.document_fields_container').setMode(showing ? 'hide' : 'show', 'document_fields');
    $('.document_fields_container .toggle').setMode(showing ? 'not' : 'is', 'enabled');
  },

  _getDocument : function(attrs, full) {
    if (full) {
      var schema = this.viewer.api.getSchema();
      attrs = _.extend({}, schema, attrs);
    }
    attrs = attrs || {};
    attrs.id = parseInt(this.viewer.api.getId(), 10);
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