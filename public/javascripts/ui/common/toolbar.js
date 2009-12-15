dc.ui.Toolbar = dc.View.extend({

  id : 'toolbar',

  callbacks : [
    ['#delete_document_button',  'click',   '_deleteSelectedDocuments'],
    // ['#bookmark_button',         'click',   '_bookmarkSelectedDocument'],
    ['#edit_summary_button',     'click',   '_editSelectedSummary']
  ],

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSelectedDocuments', '_addLabelWithDocuments', 'display');
    this.downloadMenu = this._createDownloadMenu();
    this.labelMenu = new dc.ui.LabelMenu({onClick : this._addSelectedDocuments, onAdd : this._addLabelWithDocuments});
    Documents.bind(Documents.SELECTION_CHANGED, this.display);
  },

  render : function() {
    var el = $(this.el);
    el.html(JST.workspace_toolbar({}));
    $('.download_menu_container', el).append(this.downloadMenu.render().el);
    $('.label_menu_container', el).append(this.labelMenu.render().el);
    // this.bookmarkButton = $('#bookmark_button', el);
    this.summaryButton = $('#edit_summary_button', el);
    this.setCallbacks();
    return this;
  },

  display : function() {
    var count = $('.document_tile.is_selected').length;
    count > 0 ? this.show() : this.hide();
    // this.bookmarkButton.toggleClass('disabled', count > 1);
    this.summaryButton.toggleClass('disabled', count > 1);
  },

  hide : function() {
    dc.ui.notifier.hide(true);
    $(this._panel()).setMode('closed', 'toolbar');
  },

  show : function() {
    if (!Labels.populated) Labels.populate();
    $(this._panel()).setMode('open', 'toolbar');
  },

  notifyLabeled : function(labelName, numDocs) {
    var notification = "added " + numDocs + ' ' + Inflector.pluralize('document', numDocs) + ' to "' + labelName + '"';
    dc.ui.notifier.show({mode : 'info', text : notification, anchor : this.labelMenu.el, position : 'center right', left : 7});
  },

  _addSelectedDocuments : function(label) {
    var count = Documents.countSelected();
    Labels.addSelectedDocuments(label);
    this.notifyLabeled(label.get('title'), count);
  },

  _addLabelWithDocuments : function(title) {
    var ids = Documents.selectedIds();
    var label = new dc.model.Label({title : title, document_ids : ids.join(',')});
    Labels.create(label, null, {error : function() { Labels.remove(label); }});
    this.notifyLabeled(title, ids.length);
  },

  _deleteSelectedDocuments : function() {
    var docs = Documents.selected();
    var message = 'Really delete ' + docs.length + ' ' + Inflector.pluralize('document', docs.length) + '?';
    dc.ui.Dialog.confirm(message, _.bind(function() {
      _(docs).each(function(doc){ Documents.destroy(doc); });
      this.display();
    }, this));
  },

  // _bookmarkSelectedDocument : function() {
  //   var button = this.bookmarkButton;
  //   if (button.hasClass('disabled')) return false;
  //   var doc = _.first(Documents.selected());
  //   dc.ui.Dialog.prompt("Page number to bookmark:", null, function(number) {
  //     var pageNumber = parseInt(number, 10);
  //     if (!pageNumber) return false;
  //     if (pageNumber > doc.get('page_count') || pageNumber < 1) return dc.ui.Dialog.alert('Page ' + pageNumber + ' does not exist in "' + doc.get('title') + '".');
  //     doc.bookmark(pageNumber);
  //     var notification = "added bookmark to page " + pageNumber + ' of "' + doc.get('title') + '"';
  //     dc.ui.notifier.show({mode : 'info', text : notification, anchor : button, position : 'center right', left : 7});
  //   }, true);
  // },

  _editSelectedSummary : function() {
    if (this.summaryButton.hasClass('disabled')) return false;
    var doc = _.first(Documents.selected());
    dc.ui.Dialog.prompt("Edit summary:", doc.get('summary'), function(revised) {
      if (!revised) return false;
      Documents.update(doc, {summary : Inflector.truncate(revised, 255, '')});
    });
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