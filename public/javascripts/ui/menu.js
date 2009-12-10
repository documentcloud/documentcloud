dc.ui.Menu = dc.View.extend({

  className : 'minibutton menu',

  callbacks : [
    ['el',    'click',    'open']
  ],

  constructor : function(options) {
    this.base(options);
    this.content = $.el('div', {'class' : 'menu_content', id : (this.id ? this.id + '_content' : null)});
    this.modes.open = 'not';
    _.bindAll(this, 'close');
    if (options.items) this.addItems(options.items);
  },

  render : function() {
    $(this.el).html();
    $(this.el).append($.el('span', {}, this.options.label));
    $(document.body).append(this.content);
    this.setCallbacks();
    return this;
  },

  open : function() {
    if (this.modes.open == 'is') return;
    this.setMode('is', 'open');
    if (this.options.onOpen) this.options.onOpen(this);
    $(this.content).show();
    $(this.content).align(this.el, '-left bottom', {top : 1});
    $(this.content).autohide({onHide : this.close});
  },

  close : function() {
    this.setMode('not', 'open');
    if (this.options.onClose) this.options.onClose(this);
    return true;
  },

  addItems : function(items) {
    var elements = _(items).map(function(item) {
      var el = $.el('div', {'class' : 'menu_item'}, item.title);
      if (item.onClick) el.onclick = item.onClick;
      return el;
    });
    $(this.content).append(elements);
  }

});