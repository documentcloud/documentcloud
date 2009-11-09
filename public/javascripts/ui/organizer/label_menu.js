dc.ui.LabelMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderLabels');
    options = _.extend({label : 'labels', onOpen : this.renderLabels}, options);
    this.base(options);
  },

  renderLabels : function(menu) {
    var el = $(menu.content);
    el.html('');
    Labels.each(function(label) {
      var item = $.el('div', {'class' : 'menu_item label'}, label.get('title'));
      item.onclick = function(){ menu.options.onclick(label); };
      el.append(item);
    });
  }

});