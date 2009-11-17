dc.ui.Toolbar = dc.View.extend({

  className : 'toolbar',

  constructor : function(options) {
    this.id = options.tab = '_toolbar';
    this.base(options);
    _.bindAll('_addSelectedDocuments', this);
    this.labelMenu = new dc.ui.LabelMenu({onclick : this._addSelectedDocuments});
  },

  render : function() {
    $(this.el).html(JST.workspace_toolbar({}));
    $(this.el).prepend(this.labelMenu.render().el);
    return this;
  },

  display : function() {
    var any = $('.document_tile.is_selected').length > 0;
    any ? this.show() : this.hide();
  },

  hide : function() {
    $.setMode(this._panel(), 'closed', 'toolbar');
  },

  show : function() {
    if (!Labels.populated) Labels.populate();
    $.setMode(this._panel(), 'open', 'toolbar');
  },

  _addSelectedDocuments : function(label) {
    var count = Documents.countSelected();
    var notification = "added " + count + ' ' + Inflector.pluralize('document', count) + ' to "' + label.get('title') + '"';
    dc.ui.notifier.show({mode : 'info', text : notification, anchor : this.labelMenu.el, position : 'center right', left : 7});
    Labels.addSelectedDocuments(label);
  },

  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  }

});