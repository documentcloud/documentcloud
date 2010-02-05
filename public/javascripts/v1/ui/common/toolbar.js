dc.ui.Toolbar = dc.View.extend({

  id : 'toolbar',

  callbacks : {
    '#delete_document_button.click': '_deleteSelectedDocuments',
    '#edit_summary_button.click':    '_editSelectedSummary',
    '#edit_remote_url_button.click': '_editSelectedRemoteUrl'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSelectedDocuments', '_addProjectWithDocuments', 'display');
    this.downloadMenu     = this._createDownloadMenu();
    this.accessMenu       = this._createAccessMenu();
    this.connectionsMenu  = this._createConnectionsMenu();
    this.projectMenu      = new dc.ui.ProjectMenu({onClick : this._addSelectedDocuments, onAdd : this._addProjectWithDocuments});
    Documents.bind(Documents.SELECTION_CHANGED, this.display);
  },

  render : function() {
    var el = $(this.el);
    el.html(JST.workspace_toolbar({}));
    $('.download_menu_container', el).append(this.downloadMenu.render().el);
    $('.access_menu_container', el).append(this.accessMenu.render().el);
    $('.connections_menu_container', el).append(this.connectionsMenu.render().el);
    $('.project_menu_container', el).append(this.projectMenu.render().el);
    this.summaryButton = $('#edit_summary_button', el);
    this.remoteUrlButton = $('#edit_remote_url_button', el);
    this.setCallbacks();
    return this;
  },

  display : function() {
    var count = $('.document_tile.is_selected').length;
    count > 0 ? this.show() : this.hide();
    this.summaryButton.toggleClass('disabled', count > 1);
    this.remoteUrlButton.toggleClass('disabled', count > 1);
  },

  hide : function() {
    dc.ui.notifier.hide(true);
    $(this._panel()).setMode('closed', 'toolbar');
  },

  show : function() {
    if (!Projects.populated) Projects.populate();
    $(this._panel()).setMode('open', 'toolbar');
  },

  notifyProjectChange : function(projectName, numDocs) {
    var notification = "added " + numDocs + ' ' + Inflector.pluralize('document', numDocs) + ' to "' + projectName + '"';
    dc.ui.notifier.show({mode : 'info', text : notification, anchor : this.projectMenu.el, position : '-top right', top : -1, left : 7});
  },

  _addSelectedDocuments : function(project) {
    var docs = Documents.selected();
    project.addDocuments(docs);
    this.notifyProjectChange(project.get('title'), docs.length);
  },

  _addProjectWithDocuments : function(title) {
    var ids = Documents.selectedIds();
    var project = new dc.model.Project({title : title, document_ids : ids.join(',')});
    Projects.create(project, null, {error : function() { Projects.remove(project); }});
    this.notifyProjectChange(title, ids.length);
  },

  _deleteSelectedDocuments : function() {
    var docs = Documents.selected();
    var message = 'Really delete ' + docs.length + ' ' + Inflector.pluralize('document', docs.length) + '?';
    dc.ui.Dialog.confirm(message, _.bind(function() {
      _(docs).each(function(doc){ Documents.destroy(doc); });
      this.display();
      return true;
    }, this));
  },

  _editSelectedSummary : function() {
    if (this.summaryButton.hasClass('disabled')) return false;
    var doc = _.first(Documents.selected());
    dc.ui.Dialog.prompt("Edit summary:", doc.get('summary'), function(revised) {
      if (!revised) return true;
      Documents.update(doc, {summary : Inflector.truncate(revised, 255, '')});
      return true;
    });
  },

  _editSelectedRemoteUrl : function() {
    if (this.remoteUrlButton.hasClass('disabled')) return false;
    var doc = _.first(Documents.selected());
    dc.ui.Dialog.prompt("Edit remote Url:", doc.get('remote_url'), function(revised) {
      if (!revised) return true;
      Documents.update(doc, {remote_url : revised});
      return true;
    });
  },

  _openTimeline : function() {
    new dc.ui.TimelineDialog(Documents.selected());
  },

  _openConnections : function(kind) {
    dc.app.visualizer.open(kind);
  },

  _setSelectedAccess : function(access) {
    var docs = Documents.selected();
    _.each(docs, function(doc) { Documents.update(doc, {access : access}); });
    var notification = 'access updated for ' + docs.length + ' ' + Inflector.pluralize('document', docs.length);
    dc.ui.notifier.show({mode : 'info', text : notification, anchor : this.accessMenu.el, position : '-top right', top : -1, left : 7});
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  },

  _createDownloadMenu : function() {
    return new dc.ui.Menu({
      label   : 'Download',
      items   : [
        {title : 'Download Document Viewer', onClick : Documents.downloadSelectedViewers},
        {title : 'Download as PDF',          onClick : Documents.downloadSelectedPDF},
        {title : 'Download Full Text',       onClick : Documents.downloadSelectedFullText}
      ]
    });
  },

  _createAccessMenu : function() {
    var org = dc.app.organization.name;
    return new dc.ui.Menu({
      label : 'Access',
      items : [
        {title : 'Public',          onClick : _.bind(this._setSelectedAccess, this, dc.access.PUBLIC)},
        {title : 'Only My Account', onClick : _.bind(this._setSelectedAccess, this, dc.access.PRIVATE)},
        {title : 'Only ' + org,     onClick : _.bind(this._setSelectedAccess, this, dc.access.ORGANIZATION)}
      ]
    });
  },

  _createConnectionsMenu : function() {
    var me = this;
    var items = [
      {title : 'Entities', onClick : function(){ $(document.body).toggleClass('visualize'); }},
      {title : 'Timeline', onClick : this._openTimeline, className : 'divider'}
    ];
    items = items.concat(_.map(['category', 'city', 'country', 'organization',
        'person', 'place', 'publication', 'state', 'technology', 'term'], function(kind) {
      return {title : Metadata.DISPLAY_NAME[kind], onClick : _.bind(me._openConnections, me, kind)};
    }));
    return new dc.ui.Menu({id : 'connections_menu', label : 'Connections', items : items});
  }

});