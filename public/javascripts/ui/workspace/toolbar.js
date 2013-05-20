dc.ui.Toolbar = Backbone.View.extend({

  id : 'toolbar',

  events : {
    'click #open_viewers' : '_clickOpenViewers',
    'click #size_toggle'  : '_toggleSize'
  },

  MENUS : ['edit', 'sort', 'project', 'publish', 'analyze'],

  constructor : function(options) {
    this._floating = false;
    Backbone.View.call(this, options);
    _.bindAll(this, '_updateSelectedDocuments',
      '_deleteSelectedDocuments', 'editTitle', 'editSource', 'editDescription',
      'editRelatedArticle', 'editAccess', 'openDocumentEmbedDialog', 'openNoteEmbedDialog',
      'openSearchEmbedDialog', 'openPublicationDateDialog', 'requestDownloadViewers',
      'checkFloat', '_analyzeInOverview', '_openTimeline', '_viewEntities',
      'editPublishedUrl', 'openShareDialog', '_markOrder', '_removeFromSelectedProject',
      '_enableAnalyzeMenu');
    this.sortMenu    = this._createSortMenu();
    this.analyzeMenu = this._createAnalyzeMenu();
    this.publishMenu = this._createPublishMenu();
    if (dc.account) {
      this.editMenu    = this._createEditMenu();
      this.projectMenu = new dc.ui.ProjectMenu({onClick : this._updateSelectedDocuments});
    }
  },

  render : function() {
    var el = $(this.el);
    el.html(JST['workspace/toolbar']({}));
    _.each(this.MENUS, _.bind(function(menu) {
      var view = this[menu + 'Menu'];
      if (view) $('.' + menu + '_menu_container', el).append(view.render().el);
    }, this));
    this.openButton              = this.$('#open_viewers');
    this.floatEl                 = this.$('#floating_toolbar');
    $(window).scroll(_.bind(function(){ _.defer(this.checkFloat); }, this));
    return this;
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
      }, {information : Documents.subtitle(docs.length)});
    });
  },

  editSource : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'source') || '';
      dc.ui.Dialog.prompt('Source', current, function(source) {
        _.each(docs, function(doc) { doc.save({source : source}); });
        return true;
      }, {mode : 'short_prompt', information : Documents.subtitle(docs.length)});
    });
  },

  editRelatedArticle : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'related_article') || '';
      var suffix  = docs.length > 1 ? 'these documents:' : 'this document:';
      dc.ui.Dialog.prompt('Related Article URL', current, function(rel, dialog) {
        rel = dc.inflector.normalizeUrl(rel);
        if (rel && !dialog.validateUrl(rel)) return false;
        _.each(docs, function(doc) { doc.save({related_article : rel}); });
        return true;
      }, {
        mode        : 'short_prompt',
        information : Documents.subtitle(docs.length),
        description : 'Enter the URL of the article that references ' + suffix
      });
    });
  },

  editPublishedUrl : function() {
    this.edit(function(docs) {
      var current = Documents.sharedAttribute(docs, 'remote_url') || '';
      var suffix  = docs.length > 1 ? 'these documents are' : 'this document is';
      dc.ui.Dialog.prompt('Published URL', current, function(url, dialog) {
        url = dc.inflector.normalizeUrl(url);
        if (url && !dialog.validateUrl(url)) return false;
        _.each(docs, function(doc) { doc.save({remote_url : url}); });
        return true;
      }, {
        mode        : 'short_prompt',
        information : Documents.subtitle(docs.length),
        description : 'Enter the URL at which ' + suffix + ' embedded:'
      });
    });
  },

  editAccess : function() {
    Documents.editAccess(Documents.selected());
  },

  editData : function() {
    var docs = Documents.selected();
    if (!Documents.allowedToEdit(docs)) return;
    new dc.ui.DocumentDataDialog(docs);
  },

  openViewers : function(checkEdit, suffix, afterLoad) {
    if (!Documents.selectedCount) return dc.ui.Dialog.alert('Please select a document to open.');
    var continuation = function(docs) {
      _.each(docs, function(doc){
        var win = doc.openAppropriateVersion(suffix);
        if (afterLoad) {
          win.DV || (win.DV = {});
          win.DV.afterLoad = afterLoad;
        }
      });
    };
    checkEdit ? this.edit(continuation) : continuation(Documents.selected());
  },

  openSearchEmbedDialog : function() {
    var docs = Documents.chosen();
    dc.app.searchEmbedDialog = new dc.ui.SearchEmbedDialog(docs);
  },

  openDocumentEmbedDialog : function() {
    var docs = Documents.chosen();
    if (!docs.length) return;
    if (docs.length != 1) return dc.ui.Dialog.alert('Please select a single document in order to create the embed.');
    var doc = docs[0];
    if (!doc.checkAllowedToEdit(Documents.EMBED_FORBIDDEN)) return;
    (new dc.ui.DocumentEmbedDialog(doc)).render();
  },

  openNoteEmbedDialog : function() {
    var docs = Documents.chosen();
    if (!docs.length) return;
    if (docs.length != 1) return dc.ui.Dialog.alert('Please select a single document in order to create the embed.');
    var doc = docs[0];
    if ((doc.notes.length && !doc.notes.any(function(note) { return note.get('access') == 'public'; })) ||
        (!doc.notes.length && !doc.get('public_note_count'))) {
      return dc.ui.Dialog.alert('Please select a document with at least one public note.');
    }
    if (!doc.checkAllowedToEdit(Documents.EMBED_FORBIDDEN)) return;
    dc.app.noteEmbedDialog = new dc.ui.NoteEmbedDialog(doc);
  },

  openShareDialog : function() {
    var docs = Documents.chosen();
    if (!docs.length || !Documents.allowedToEdit(docs)) return;
    dc.app.shareDialog = new dc.ui.ShareDialog({docs: docs, mode: 'custom'});
  },

  openCurrentProject : function() {
    Projects.firstSelected().edit();
  },

  openPublicationDateDialog : function() {
    var docs = Documents.chosen();
    if (!docs.length || !Documents.allowedToEdit(docs)) return;
    new dc.ui.PublicationDateDialog(docs);
  },

  requestDownloadViewers : function() {
    if (dc.account.organization().get('demo')) return dc.ui.Dialog.alert('Demo accounts are not allowed to download viewers. <a href="/contact">Contact us</a> if you need a full featured account.');
    var docs = Documents.chosen();
    if (docs.length) Documents.downloadViewers(docs);
  },

  checkFloat : function() {
    var open = dc.app.navigation.isOpen('search');
    var floating = open && ($(window).scrollTop() > $(this.el).offset().top - 30);
    if (this._floating == floating) return;
    $(document.body).toggleClass('floating_toolbar', this._floating = floating);
  },

  _updateSelectedDocuments : function(project) {
    var docs    = Documents.selected();
    var removal = project.containsAny(docs);
    removal ? project.removeDocuments(docs) : project.addDocuments(docs);
  },

  _removeFromSelectedProject : function() {
    var docs    = Documents.selected();
    var project = Projects.firstSelected();
    project.removeDocuments(docs);
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

  _analyzeInOverview : function() {
    var query;

    if (Documents.selectedCount) {
      var docs = Documents.chosen();
      query = _.map(docs, function(doc) { return 'document:' + doc.id }).join(' ');
    } else {
      query = dc.app.searcher.publicQuery();
    }

    if (/\S/.test(query)) {
      dc.ui.Dialog.confirm(
        'You are about to export to Overview. You must create an Overview account, and you must provide Overview with your DocumentCloud username and password.',
        function() { window.open("https://www.overviewproject.org/imports/documentcloud/new/" + encodeURIComponent(query), '_blank'); },
        {
          saveText: 'Export',
          closeText: 'Cancel'
        }
      );
    } else {
      // Overview will refuse to import all DocumentCloud documents at once
      dc.ui.Dialog.alert("In order to analyze documents in Overview, please select a project or some documents.");
    }
  },

  _viewEntities : function() {
    var docs = Documents.chosen();
    if (!docs.length && Documents.selectedCount) return;
    if (docs.length <= 0) docs = Documents.models;

    // Old implementation:
    // if (!docs.length) return dc.app.navigation.open('entities');
    // dc.app.searcher.viewEntities(docs);
    dc.app.paginator.ensureRows(function(){
      dc.model.EntitySet.populateDocuments(docs);
    }, docs[0]);
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  },

  _chooseSort : function(e) {
    dc.app.paginator.setSortOrder($(e.target).attr('data-order'));
  },

  _markOrder : function(menu) {
    $('.menu_item', menu.content).removeClass('checked')
      .filter('[data-order="' + dc.app.paginator.sortOrder + '"]').addClass('checked');
  },

  _enableMenuItems : function(menu) {
    var total       = Documents.length;
    var count       = Documents.selectedCount;
    var publicCount = Documents.selectedPublicCount();
    $('.menu_item:not(.plus,.always)', menu.content)
      .toggleClass('disabled', !count)
      .attr('title', count ? '' : 'No documents selected');
    $('.singular', menu.content)
      .toggleClass('disabled', !(count == 1));
    $('.private_only', menu.content)
      .toggleClass('disabled', !count || publicCount > 0).
      attr('title', count && publicCount > 0 ? "already public" : '');
    $('.menu_item.always', menu.content)
      .toggleClass('disabled', !total);
    $('.menu_item.project', menu.content)
      .toggleClass('hidden', !Projects.firstSelected());
  },

  _enableAnalyzeMenu : function(menu) {
    this._enableMenuItems(menu);
    var singular = Documents.selectedCount == 1;
    $('.share_documents', menu.content).text(singular ? 'Share this Document' : 'Share these Documents');
    $('.share_project', menu.content).toggleClass('disabled', !Projects.selectedCount);
    var overviewWillAnalyzeProject = !Documents.selectedCount && !!Projects.firstSelected();
    var overviewDisabled = !Documents.selectedCount && !/\S/.test(dc.app.searcher.publicQuery());
    $('.menu_item.analyze_in_overview', menu.content)
      .toggleClass('disabled', overviewDisabled)
      .attr('title', overviewDisabled ? 'No project or documents selected' : '')
      .text(overviewWillAnalyzeProject
            ? 'Analyze this Project in Overview'
            : (singular ? 'Analyze this Document in Overview' : 'Analyze these Documents in Overview'));
  },

  _createPublishMenu : function() {
    var accountItems = [
      {title : 'Embed Document Viewer',    onClick : this.openDocumentEmbedDialog,    attrs: {'class': 'singular'}},
      {title : 'Embed Document List',      onClick : this.openSearchEmbedDialog,      attrs: {'class': 'always'}},
      {title : 'Embed a Note',             onClick : this.openNoteEmbedDialog,        attrs: {'class': 'singular'}},
      {title : 'Set Publication Date',     onClick : this.openPublicationDateDialog,  attrs: {'class': 'private_only'}},
      {title : 'Download Document Viewer', onClick : this.requestDownloadViewers}
    ];
    var publicItems = [
      {title : 'Download Original PDF',    onClick : Documents.downloadSelectedPDF},
      {title : 'Download Full Text',       onClick : Documents.downloadSelectedFullText},
      {title : 'Print Notes',              onClick : Documents.printNotes}
    ];
    var items = dc.account ? accountItems.concat(publicItems) : publicItems;
    return new dc.ui.Menu({
      label   : dc.account ? 'Publish' : 'Save',
      onOpen  : this._enableMenuItems,
      items   : items
    });
  },

  _createSortMenu : function() {
    return new dc.ui.Menu({
      label   : 'Sort',
      onOpen  : this._markOrder,
      items   : [
        {title: 'Sort by Relevance',     attrs: {'data-order' : 'score'},      onClick : this._chooseSort},
        {title: 'Sort by Date Uploaded', attrs: {'data-order' : 'created_at'}, onClick : this._chooseSort},
        {title: 'Sort by Title',         attrs: {'data-order' : 'title'},      onClick : this._chooseSort},
        {title: 'Sort by Source',        attrs: {'data-order' : 'source'},     onClick : this._chooseSort},
        {title: 'Sort by Length',        attrs: {'data-order' : 'page_count'}, onClick : this._chooseSort}
      ]
    });
  },

  _createEditMenu : function() {
    return new dc.ui.Menu({
      label   : 'Edit',
      onOpen  : this._enableMenuItems,
      items   : [
        {title : 'Edit Document Information', attrs: {'class' : 'multiple'},        onClick : function(){ dc.ui.DocumentDialog.open(); }},
        {title : 'Title',                     attrs: {'class' : 'singular indent'}, onClick : this.editTitle},
        {title : 'Source',                    attrs: {'class' : 'multiple indent'}, onClick : this.editSource},
        {title : 'Description',               attrs: {'class' : 'multiple indent'}, onClick : this.editDescription},
        {title : 'Access Level',              attrs: {'class' : 'multiple indent'}, onClick : this.editAccess},
        {title : 'Related Article URL',       attrs: {'class' : 'multiple indent'}, onClick : this.editRelatedArticle},
        {title : 'Published URL',             attrs: {'class' : 'multiple indent'}, onClick : this.editPublishedUrl},
        {title : 'Edit Document Data',        attrs: {'class' : 'multiple'},        onClick : this.editData},
        {title : 'Modify Original Document',  attrs: {'class' : 'multiple'},        onClick : _.bind(this.openViewers, this, true, '#pages', null)},
        {title : 'Remove from this Project',  attrs: {'class' : 'multiple project'},onClick : this._removeFromSelectedProject},
        {title : 'Delete Documents',          attrs: {'class' : 'multiple warn'},   onClick : this._deleteSelectedDocuments}
      ]
    });
  },

  _createAnalyzeMenu : function() {
    var publicItems = [
      {title: 'View Entities',          attrs: {'class' : 'always'},   onClick : this._viewEntities},
      {title: 'View Timeline',          attrs: {'class' : 'always'},   onClick : this._openTimeline}
    ];
    var accountItems = [
      {title: 'Analyze these Documents in Overview', attrs: {'class' : 'always analyze_in_overview'}, onClick : this._analyzeInOverview },
      {title: 'Share these Documents',               attrs: {'class' : 'multiple share_documents'},   onClick : this.openShareDialog },
      {title: 'Share this Project',                  attrs: {'class' : 'share_project'},              onClick : this.openCurrentProject }
    ];
    return new dc.ui.Menu({
      label   : 'Analyze',
      onOpen  : this._enableAnalyzeMenu,
      items   : dc.account ? publicItems.concat(accountItems) : publicItems
    });
  },

  _openEditPageTextEditor: function(viewer) {
    _.defer(function(){ viewer.window.dc.app.editor.editPageTextEditor.open(); });
  },

  _openInsertEditor  : function(viewer) {
    _.defer(function(){ viewer.window.dc.app.editor.replacePagesEditor.open(); });
  },

  _openRemoveEditor  : function(viewer) {
    _.defer(function(){ viewer.window.dc.app.editor.removePagesEditor.open(); });
  },

  _openReorderEditor : function(viewer) {
    _.defer(function(){ viewer.window.dc.app.editor.reorderPagesEditor.open(); });
  },

  _clickOpenViewers : function() {
    this.openViewers();
  },

  _toggleSize : function() {
    dc.app.paginator.toggleSize();
  }

});
