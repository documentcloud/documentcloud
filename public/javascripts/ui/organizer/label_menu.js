dc.ui.LabelMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderLabels');
    options = _.extend({label : 'labels', onOpen : this.renderLabels, onClose : this._shouldClose, autofilter : true}, options);
    this.base(options);
  },

  renderLabels : function(menu) {
    menu.clear();
    menu.addItems(_.map(Labels.models(), function(label) {
      return {title : label.get('title'), onClick : _.bind(menu.options.onclick, menu, label)};
    }));
  },

  _shouldClose : function(e) {
    return e && !$(e.target).hasClass('autofilter_input');
  }

});