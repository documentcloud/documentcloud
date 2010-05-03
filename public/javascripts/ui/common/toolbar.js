dc.ui.Toolbar = dc.View.extend({

  id : 'toolbar',

  callbacks : {
    '#calais_credits.click' : '_openCalais',
    '#open_viewers.click'   : '_openViewers',
    '#open_timeline.click'  : '_openTimeline',
    '#toolbar_upload.click' : '_openUpload'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_updateSelectedDocuments', '_addProjectWithDocuments',
      '_registerDocument', '_deleteSelectedDocuments', 'editTitle', 'editSource',
      'editDescription', 'editRelatedArticle', 'editAccess', 'display');
    this.editMenu         = this._createEditMenu();
    this.downloadMenu     = this._createDownloadMenu();
    // this.connectionsMenu  = this._createConnectionsMenu();
    this.projectMenu      = new dc.ui.ProjectMenu({onClick : this._updateSelectedDocuments, onAdd : this._addProjectWithDocuments});
    Documents.bind(Documents.SELECTION_CHANGED, this.display);
    Documents.bind(dc.Set.REFRESHED, this.display);
  },

  render : function() {
    var el = $(this.el);
    el.html(JST.workspace_toolbar({}));
    $('.edit_menu_container', el).append(this.editMenu.render().el);
    $('.download_menu_container', el).append(this.downloadMenu.render().el);
    // $('.connections_menu_container', el).append(this.connectionsMenu.render().el);
    $('.project_menu_container', el).append(this.projectMenu.render().el);
    this.remoteUrlButton = $('#edit_remote_url_button', el);
    this.openButton      = $('#open_viewers', this.el);
    this.timelineButton  = $('#open_timeline', this.el);
    this.setCallbacks();
    this.display();
    return this;
  },

  display : function() {
    var count = Documents.countSelected();
    var mode  = count == 0 ? 'not' : 'is';
    this.openButton.setMode(mode, 'enabled');
    this.timelineButton.setMode(mode, 'enabled');
    _.each([this.downloadMenu, this.editMenu, this.projectMenu], function(menu) {
      count == 0 ? menu.disable() : menu.enable();
    });
  },

  notifyProjectChange : function(projectName, numDocs, removal) {
    var prefix = removal ? 'Removed ' : 'Added ';
    var prep   = removal ? ' from "'  : ' to "';
    var notification = prefix + numDocs + ' ' + Inflector.pluralize('document', numDocs) + prep + projectName + '"';
    dc.ui.notifier.show({mode : 'info', text : notification});
  },

  // Wrapper function for safely editing an attribute of a specific document.
  edit : function(callback) {
    if (!Documents.allowedToEditSelected()) return;
    return callback.call(this, Documents.selected());
  },

  editTitle : function() {
    this.edit(function(docs) {
      var doc = docs[0];
      dc.ui.Dialog.prompt('Title', doc.get('title'), function(title) {
        Documents.update(doc, {title : title});
        return true;
      }, true);
    });
  },

  editDescription : function() {
    this.edit(function(docs) {
      var doc = docs[0];
      dc.ui.Dialog.prompt('Description', doc.get('description'), function(description) {
        Documents.update(doc, {description : description});
        return true;
      });
    });
  },

  editSource : function() {
    this.edit(function(docs) {
      var sources = _.uniq(_.map(docs, function(doc){ return doc.get('source'); }));
      var current = sources.length > 1 ? '' : sources[0];
      dc.ui.Dialog.prompt('Source' + this._subtitle(docs.length), current, function(source) {
        _.each(docs, function(doc) { Documents.update(doc, {source : source}); });
        return true;
      }, true);
    });
  },

  editRelatedArticle : function() {
    this.edit(function(docs) {
      var articles = _.uniq(_.map(docs, function(doc){ return doc.get('related_article'); }));
      var current  = articles.length > 1 ? '' : articles[0];
      dc.ui.Dialog.prompt('Related Article' + this._subtitle(docs.length), current, function(rel) {
        _.each(docs, function(doc) { Documents.update(doc, {related_article : rel}); });
        return true;
      }, true);
    });
  },

  editAccess : function() {
    if (!Documents.allowedToEditSelected()) return;
    var docs    = Documents.selected();
    var access  = _.uniq(_.map(docs, function(doc){ return doc.get('access'); }));
    var current = access.length > 1 ? dc.access.PRIVATE : access[0];
    dc.ui.Dialog.choose('Access Level' + this._subtitle(docs.length), [
      {text : 'Public Access',              value : dc.access.PUBLIC,       selected : current == dc.access.PUBLIC},
      {text : 'Private Access',             value : dc.access.PRIVATE,      selected : current == dc.access.PRIVATE},
      {text : 'Private to my Organization', value : dc.access.ORGANIZATION, selected : current == dc.access.ORGANIZATION}
    ], _.bind(function(access) {
      _.each(docs, function(doc) { Documents.update(doc, {access : parseInt(access, 10)}); });
      var notification = 'Access updated for ' + docs.length + ' ' + Inflector.pluralize('document', docs.length);
      dc.ui.notifier.show({mode : 'info', text : notification});
      return true;
    }, this));
  },

  _subtitle : function(count) {
    return count > 1 ? ' <span class="subtitle">(' + count + ' Documents)</span>' : '';
  },

  _updateSelectedDocuments : function(project) {
    var docs = Documents.selected();
    var removal = project.containsAny(docs);
    removal ? project.removeDocuments(docs) : project.addDocuments(docs);
    this.notifyProjectChange(project.get('title'), docs.length, removal);
  },

  _addProjectWithDocuments : function(title) {
    var ids = Documents.selectedIds();
    var project = new dc.model.Project({title : title, annotation_count : 0, document_ids : ids.join(',')});
    Projects.create(project, null, {error : function() { Projects.remove(project); }});
    this.notifyProjectChange(title, ids.length);
  },

  _deleteSelectedDocuments : function() {
    if (!Documents.allowedToEditSelected()) return;
    var docs = Documents.selected();
    var message = 'Really delete ' + docs.length + ' ' + Inflector.pluralize('document', docs.length) + '?';
    dc.ui.Dialog.confirm(message, _.bind(function() {
      _(docs).each(function(doc){ Documents.destroy(doc); });
      dc.app.documentCount -= docs.length;
      dc.ui.Project.uploadedDocuments.render();
      Projects.removeDocuments(docs);
      this.display();
      return true;
    }, this));
  },

  _registerDocument : function() {
    var docs = Documents.selected();
    if (docs.length > 1) return dc.ui.Dialog.alert('Please register only a single published document at a time.');
    var doc = docs[0];
    dc.ui.Dialog.prompt("Enter URL of Published Document", doc.get('remote_url'), function(revised) {
      Documents.update(doc, {remote_url : revised});
      return true;
    }, 'short');
  },

  _openTimeline : function() {
    var docs = Documents.selected();
    if (!docs.length) return;
    new dc.ui.TimelineDialog(docs);
  },

  _openUpload : function() {
    dc.app.uploader.open();
  },

  _openConnections : function(kind) {
    dc.app.visualizer.open(kind);
  },

  _openEntities : function() {
    dc.app.entities.open();
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  },

  _createDownloadMenu : function() {
    return new dc.ui.Menu({
      label   : 'Download',
      items   : [
        // {title : 'Download Document Viewer', onClick : Documents.downloadSelectedViewers},
        {title : 'Download as PDF',          onClick : Documents.downloadSelectedPDF},
        {title : 'Download Full Text',       onClick : Documents.downloadSelectedFullText}
      ]
    });
  },

  _createEditMenu : function() {
    return new dc.ui.Menu({
      label   : 'Edit',
      items   : [
        {title : 'Edit Title',           className : 'singular', onClick : this.editTitle},
        {title : 'Edit Description',     className : 'singular', onClick : this.editDescription},
        {title : 'Edit Source',          className : 'multiple', onClick : this.editSource},
        {title : 'Edit Related Article', className : 'multiple', onClick : this.editRelatedArticle},
        {title : 'Edit Access Level',    className : 'multiple', onClick : this.editAccess},
        {title : 'Delete Documents',     className : 'multiple warn', onClick : this._deleteSelectedDocuments}
      ],
      onOpen : function(menu) {
        var many = Documents.countSelected() > 1;
        $('.singular', menu.content).toggleClass('disabled', many);
      }
    });
  },

  _createConnectionsMenu : function() {
    var me = this;
    var items = [
      // {title : 'Entities', onClick : this._openEntities},
      {title : 'Timeline', onClick : this._openTimeline, className : 'divider'}
    ];
    items = items.concat(_.map(['city', 'country', 'organization',
        'person', 'place', 'state', 'term'], function(kind) {
      return {title : Entities.DISPLAY_NAME[kind], onClick : _.bind(me._openConnections, me, kind)};
    }));
    return new dc.ui.Menu({id : 'connections_menu', label : 'Connections', items : items});
  },

  _openCalais : function() {
    window.open('http://opencalais.com');
  },

  _openViewers : function() {
    _.each(Documents.selected(), function(doc){ doc.openViewer(); });
  }

});