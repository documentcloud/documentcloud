dc.ui.Toolbar = dc.View.extend({
  
  className : 'toolbar',
    
  constructor : function(options) {
    this.id = options.tab = '_toolbar';
    this.base(options);
    _.bindAll('renderLabels', this);
    this.labelMenu = new dc.ui.Menu({label : 'labels', onOpen : this.renderLabels});
  },
  
  render : function() {
    $(this.el).html(dc.templates.WORKSPACE_TOOLBAR({}));
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
  
  renderLabels : function(menu) {
    var el = $(menu.content);
    el.html('');
    Labels.each(function(label) {
      var item = $.el('div', {'class' : 'menu_item label'}, label.get('title'));
      item.onclick = label.addSelectedDocuments;
      el.append(item);
    });
  },
  
  _panel : function() {
    return this._panelEl = this._panelEl || $(this.el).parents('.panel_content')[0];
  }
  
});