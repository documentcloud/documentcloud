dc.ui.LabelMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderLabels');
    options = _.extend({label : 'label', onOpen : this.renderLabels}, options);
    this.base(options);
  },

  renderLabels : function(menu) {
    $(menu.content).html('');
    menu.addItems(_.map(Labels.models(), function(label) {
      return {title : label.get('title'), onClick : _.bind(menu.options.onclick, menu, label)};
    }));
  }

});