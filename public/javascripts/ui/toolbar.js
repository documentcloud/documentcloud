dc.ui.Toolbar = dc.View.extend({

  className : 'toolbar',

  callbacks : [
    ['#delete_document_button',  'click',   '_deleteSelectedDocuments']
  ],

  constructor : function(options) {
    this.id = options.tab = '_toolbar';
    this.base(options);
    _.bindAll('_addSelectedDocuments', this);
    this.downloadMenu = this._createDownloadMenu();
    this.labelMenu = new dc.ui.LabelMenu({onclick : this._addSelectedDocuments});
  },

  render : function() {
    var el = $(this.el);
    el.html(JST.workspace_toolbar({}));
    el.prepend(this.downloadMenu.render().el);
    el.prepend(this.labelMenu.render().el);
    this.setCallbacks();
    return this;
  },

  display : function() {
    var any = $('.document_tile.is_selected').length > 0;
    any ? this.show() : this.hide();
  },

  hide : function() {
    dc.ui.notifier.hide(true);
    $(this._panel()).setMode('closed', 'toolbar');
  },

  show : function() {
    if (!Labels.populated) Labels.populate();
    $(this._panel()).setMode('open', 'toolbar');
  },

  _addSelectedDocuments : function(label) {
    var count = Documents.countSelected();
    var notification = "added " + count + ' ' + Inflector.pluralize('document', count) + ' to "' + label.get('title') + '"';
    dc.ui.notifier.show({mode : 'info', text : notification, anchor : this.labelMenu.el, position : 'center right', left : 7});
    Labels.addSelectedDocuments(label);
  },

  _deleteSelectedDocuments : function() {
    var docs = Documents.selected();
    if (!confirm('Really delete ' + docs.length + ' ' + Inflector.pluralize('document', docs.length) + '?')) return;
    _(docs).each(function(doc){ Documents.destroy(doc); });
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  },

  _createDownloadMenu : function() {
    return new dc.ui.Menu({
      label   : 'download',
      items   : [
        {title : 'Download Document Viewer', onClick : Documents.downloadSelectedViewers},
        {title : 'Download as PDF',          onClick : Documents.downloadSelectedPDF},
        {title : 'Download Full Text',       onClick : Documents.downloadSelectedFullText}
      ]
    });
  }

});