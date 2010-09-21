dc.ui.Menu = dc.Controller.extend({

  className : 'minibutton menu',

  options : {id : null, standalone : false},

  callbacks : {
    'el.click'        : 'open',
    'el.selectstart'  : '_stopSelect'
  },

  constructor : function(options) {
    _.bindAll(this, 'close');
    this.base(options);
    this.items          = [];
    this.content        = $(JST['common/menu'](this.options));
    this.itemsContainer = $('.menu_items', this.content);
    this.addIcon        = $('.bullet_add', this.content);
    this.modes.open     = 'not';
    if (options.items) this.addItems(options.items);
  },

  render : function() {
    $(this.el).html(JST['common/menubutton']({label : this.options.label}));
    this._label = this.$('.label');
    $(document.body).append(this.content);
    this.setCallbacks();
    return this;
  },

  open : function() {
    var content = this.content;
    if (this.modes.enabled == 'not') return false;
    if (this.modes.open == 'is' && !this.options.standalone) return this.close();
    this.setMode('is', 'open');
    if (this.options.onOpen) this.options.onOpen(this);
    content.show();
    content.align(this.el, '-left bottom no-constraint');
    content.autohide({onHide : this.close});
    return this;
  },

  close : function(e) {
    if (e && this.options.onClose && !this.options.onClose(e)) return false;
    this.setMode('not', 'open');
    return true;
  },

  enable : function() {
    this.setMode('is', 'enabled');
  },

  disable : function() {
    this.setMode('not', 'enabled');
  },

  // Show the menu button as being currently open, with another click required
  // to close it.
  activate : function(callback) {
    this._activateCallback = callback;
    this.setMode('is', 'active');
  },

  deactivate : function(e) {
    if (this.modes.active == 'is') {
      this.setMode('not', 'active');
      if (this._activateCallback) this._activateCallback();
      return false;
    }
  },

  clear : function() {
    this.items = [];
    $(this.itemsContainer).html('');
    this.content.setMode(null, 'selected');
  },

  setLabel : function(label) {
    $(this._label).text(label || this.options.label);
  },

  addItems : function(items) {
    this.items = this.items.concat(items);
    var elements = _(items).map(_.bind(function(item) {
      var attrs = item.attrs || {};
      _.extend(attrs, {'class' : 'menu_item ' + attrs['class']});
      var el = this.make('div', attrs, item.title);
      item.menuEl = $(el);
      if (item.onClick) $(el).bind('click', function(e) {
        if ($(el).hasClass('disabled')) return false;
        item.onClick(e);
      });
      return el;
    }, this));
    $(this.itemsContainer).append(elements);
  },

  select : function(item) {
    this.selectedItem = item;
    item.menuEl.addClass('selected');
  },

  deselect : function() {
    if (this.selectedItem) this.selectedItem.menuEl.removeClass('selected');
    this.selectedItem = null;
  },

  _stopSelect : function(e) {
    return false;
  }

});