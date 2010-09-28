dc.ui.Toolbar = dc.Controller.extend({

  id : 'toolbar',

  callbacks : {
    '#open_viewers.click' : '_openViewers'
  },

  MENUS : ['project', 'edit', 'publish', 'analyze'],

  constructor : function(options) {
    this._floating = false;
    this.base(options);
    _.bindAll(this, '_updateSelectedDocuments',
      '_deleteSelectedDocuments', 'editTitle', 'editSource', 'editDescription',
      'editRelatedArticle', 'editAccess', 'openEmbedDialog', 'requestDownloadViewers',
      'checkFloat', '_openTimeline', '_viewEntities', 'editDocumentURL');
    this.editMenu         = this._createEditMenu();
    this.publishMenu      = this._createPublishMenu();
    this.analyzeMenu      = this._createAnalyzeMenu();
    this.projectMenu      = new dc.ui.ProjectMenu({onClick : this._updateSelectedDocuments});
  },

  render : function() {
    var el = $(this.el);
    el.html(JST['workspace/toolbar']({}));
    _.each(this.MENUS, _.bind(function(menu){
      $('.' + menu + '_menu_container', el).append(this[menu + 'Menu'].render().el);
    }, this));
    this.openButton              = this.$('#open_viewers');
    this.floatEl                 = this.$('#floating_toolbar');
    $(window).scroll(_.bind(function(){ _.defer(this.checkFloat); }, this));
    this.setCallbacks();
    return this;
  },

  notifyProjectChange : function(projectName, numDocs, removal) {
    var prefix = removal ? 'Removed ' : 'Added ';
    var prep   = removal ? ' from "'  : ' to "';
    var notification = prefix + numDocs + ' ' + Inflector.pluralize('document', numDocs) + prep + projectName + '"';
    dc.ui.notifier.show({mode : 'info', text : notification});
  },

  // Wrapper function for safely editing an attribute of a specific document.
  edit : function(callback, message) {
    var docs = Documents.selected();
    if (!Documents.allowedToEdit(docs, message)) return;
    return callback.call(this, docs);
  },

  editTitle : function() {
    this.edit(function(docs) {
      var doc = docs[0];
      dc.ui.Dialog.prompt('Title', doc.get('title'), function(title) {
        doc.save({title : title});
        return true;
      }, {mode : 'short_prompt'});
    });
  },

  editDescription : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'description') || '';
      dc.ui.Dialog.prompt('Description', current, function(description) {
        _.each(docs, function(doc) { doc.save({description : description}); });
        return true;
      }, {information : this._subtitle(docs.length)});
    });
  },

  editSource : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'source') || '';
      dc.ui.Dialog.prompt('Source', current, function(source) {
        _.each(docs, function(doc) { doc.save({source : source}); });
        return true;
      }, {mode : 'short_prompt', information : this._subtitle(docs.length)});
    });
  },

  editRelatedArticle : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'related_article') || '';
      var suffix  = docs.length > 1 ? 'these documents:' : 'this document:';
      dc.ui.Dialog.prompt('Related Article URL', current, function(rel, dialog) {
        rel = Inflector.normalizeUrl(rel);
        if (rel && !dialog.validateUrl(rel)) return false;
        _.each(docs, function(doc) { doc.save({related_article : rel}); });
        return true;
      }, {
        mode        : 'short_prompt',
        information : this._subtitle(docs.length),
        description : 'Enter the URL of the article that references ' + suffix
      });
    });
  },

  editDocumentURL : function() {
    this.edit(function(docs) {
      var doc = docs[0];
      dc.ui.Dialog.prompt('Document URL', doc.get('remote_url'), function(url, dialog) {
        url = Inflector.normalizeUrl(url);
        if (url && !dialog.validateUrl(url)) return false;
        doc.save({remote_url : url});
        return true;
      }, {
        mode        : 'short_prompt',
        description : 'Enter the URL of the page on which this document is embedded:'
      });
    });
  },

  editAccess : function() {
    var docs    = Documents.selected();
    var options = {information : this._subtitle(docs.length)};
    Documents.editAccess(docs, options);
  },

  openEmbedDialog : function() {
    var docs = Documents.chosen();
    if (!docs.length) return;
    if (docs.length != 1) return dc.ui.Dialog.alert('Please select a single document in order to create the embed.');
    var doc = docs[0];
    if (!doc.checkAllowedToEdit(Documents.EMBED_FORBIDDEN)) return;
    (new dc.ui.PublishPreview(doc)).render();
  },

  requestDownloadViewers : function() {
    if (dc.app.organization.demo) return dc.ui.Dialog.alert('Demo accounts are not allowed to download viewers. <a href="/contact">Contact us</a> if you need a full featured account.');
    var docs = Documents.chosen();
    if (docs.length) Documents.downloadViewers(docs);
  },

  checkFloat : function() {
    var open = dc.app.navigation.isOpen('search');
    var floating = open && ($(window).scrollTop() > $(this.el).offset().top - 30);
    if (this._floating == floating) return;
    $(document.body).toggleClass('floating_toolbar', this._floating = floating);
  },

  _subtitle : function(count) {
    return count > 1 ? count + ' Documents' : '';
  },

  _updateSelectedDocuments : function(project) {
    var docs = Documents.selected();
    var removal = project.containsAny(docs);
    removal ? project.removeDocuments(docs) : project.addDocuments(docs);
    this.notifyProjectChange(project.get('title'), docs.length, removal);
  },

  _deleteSelectedDocuments : function() {
    Documents.verifyDestroy(Documents.selected());
  },

  // Open up a Timeline. Limit the number of documents to ten. If no documents
  // are selected, choose the first ten docs.
  _openTimeline : function() {
    var docs = Documents.chosen();
    if (!docs.length && Documents.selectedCount) return;
    if (docs.length > 10) return dc.ui.Dialog.alert("You can only view a timeline for ten documents at a time.");
    if (docs.length <= 0) docs = Documents.models.slice(0, 10);
    if (docs.length <= 0) return dc.ui.Dialog.alert("In order to view a timeline, please select some documents.");
    new dc.ui.TimelineDialog(docs);
  },

  _openRelatedDocuments : function() {
    var docs = Documents.chosen();
    if (!docs.length) return;
    if (docs.length != 1) return dc.ui.Dialog.alert("Please select a single document, in order to view related documents.");
    dc.app.searcher.search('related: ' + docs[0].id + '-' + docs[0].attributes().slug);
  },

  _viewEntities : function() {
    var docs = Documents.chosen();
    if (!docs.length && Documents.selectedCount) return;
    if (!docs.length) return dc.app.navigation.open('entities');
    dc.app.searcher.viewEntities(docs);
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  },

  _enableMenuItems : function(menu) {
    $('.menu_item:not(.plus,.always)', menu.content)
      .toggleClass('disabled', !Documents.selectedCount)
      .attr('title', Documents.selectedCount ? '' : 'No documents selected');
    $('.singular', menu.content).toggleClass('disabled', !(Documents.selectedCount == 1));
  },

  _createPublishMenu : function() {
    return new dc.ui.Menu({
      label   : 'Publish',
      onOpen  : this._enableMenuItems,
      items   : [
        {title : 'Embed Document Viewer',    onClick : this.openEmbedDialog},
        {title : 'Download Document Viewer', onClick : this.requestDownloadViewers},
        {title : 'Download Original PDF',    onClick : Documents.downloadSelectedPDF},
        {title : 'Download Full Text',       onClick : Documents.downloadSelectedFullText}
      ]
    });
  },

  _createEditMenu : function() {
    return new dc.ui.Menu({
      label   : 'Edit',
      onOpen  : this._enableMenuItems,
      items   : [
        {title : 'Edit All Fields',           attrs: {'class' : 'multiple'},        onClick : function(){ dc.ui.DocumentDialog.open(); }},
        {title : 'Edit Title',                attrs: {'class' : 'singular indent'}, onClick : this.editTitle},
        {title : 'Edit Source',               attrs: {'class' : 'multiple indent'}, onClick : this.editSource},
        {title : 'Edit Description',          attrs: {'class' : 'multiple indent'}, onClick : this.editDescription},
        {title : 'Edit Related Article URL',  attrs: {'class' : 'multiple indent'}, onClick : this.editRelatedArticle},
        {title : 'Edit Document URL',         attrs: {'class' : 'singular indent'}, onClick : this.editDocumentURL},
        {title : 'Edit Access Level',         attrs: {'class' : 'multiple indent'}, onClick : this.editAccess},
        {title : 'Delete Documents',          attrs: {'class' : 'multiple warn'},   onClick : this._deleteSelectedDocuments}
      ]
    });
  },

  _createAnalyzeMenu : function() {
    return new dc.ui.Menu({
      label   : 'Analyze',
      onOpen  : this._enableMenuItems,
      items   : [
        {title: 'View Entities',          attrs: {'class' : 'always'},   onClick : this._viewEntities},
        {title: 'View Timeline',          attrs: {'class' : 'always'},   onClick : this._openTimeline},
        {title: 'Find Related Documents', attrs: {'class' : 'singular'}, onClick : this._openRelatedDocuments}
      ]
    });
  },

  _openViewers : function() {
    if (!Documents.selectedCount) return dc.ui.Dialog.alert('Please select a document to open.');
    _.each(Documents.selected(), function(doc){ doc.openViewer(); });
  }

});
