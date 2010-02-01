dc.ui.Menu = dc.View.extend({

  className : 'minibutton menu',

  callbacks : {
    'el.click': 'open'
  },

  constructor : function(options) {
    _.bindAll(this, 'close', 'autofilter');
    options.id = options.id || null;
    this.base(options);
    this.items          = [];
    this.content        = $(JST.menu(this.options));
    this.itemsContainer = $('.menu_items', this.content);
    this.filter         = $('.autofilter_input', this.content);
    this.addIcon        = $('.bullet_add', this.content);
    this.modes.open     = 'not';
    if (options.items) this.addItems(options.items);
  },

  defaultOptions : function() {
    return {id : null, autofilter : false};
  },

  render : function() {
    $(this.el).html($.el('span', {}, this.options.label));
    $(document.body).append(this.content);
    this.setCallbacks();
    if (this.options.autofilter) this.filter.bind('keyup', this.autofilter);
    return this;
  },

  open : function() {
    if (this.modes.open == 'is') return;
    this.setMode('is', 'open');
    if (this.options.onOpen) this.options.onOpen(this);
    this.content.show();
    this.content.align(this.el, '-left bottom', {top : 1});
    this.content.autohide({onHide : this.close});
    if (this.options.autofilter) $('input', this.content).focus();
  },

  close : function(e) {
    if (e && this.options.onClose && !this.options.onClose(e)) return false;
    this.setMode('not', 'open');
    return true;
  },

  clear : function() {
    this.filter.val('');
    this.items = [];
    $(this.itemsContainer).html('');
    this.content.setMode(null, 'selected');
  },

  addItems : function(items) {
    this.items = this.items.concat(items);
    var elements = _(items).map(function(item) {
      var el = $.el('div', {'class' : 'menu_item'}, item.title);
      item.menuEl = $(el);
      if (item.onClick) $(el).bind('click', item.onClick);
      return el;
    });
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

  clickSelectedItem : function() {
    this.content.forceHide();
    if (this.selectedItem) return this.selectedItem.onClick();
    var val = this.filter.val();
    if (val) this.options.onAdd(val);
  },

  autofilter : function(e) {
    if (e.keyCode == 27) return this.content.forceHide();
    if (e.keyCode == 13) return this.clickSelectedItem();
    var count   = 0;
    var search  = this.filter.val();
    var matcher = new RegExp(this.filter.val(), 'i');
    this.deselect();
    _.each(this.items, _.bind(function(item) {
      var selected = !!item.title.match(matcher);
      item.menuEl.toggle(selected);
      if (!selected) return;
      count++;
      if (!this.selectedItem) this.select(item);
    }, this));
    this.content.setMode(count ? 'some' : 'none', 'selected');
  }

});