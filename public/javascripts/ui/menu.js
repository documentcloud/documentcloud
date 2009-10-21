// The Sidebar. Switches contexts between different subviews.
dc.ui.Menu = dc.View.extend({
  
  className : 'minibutton item menu',
  
  callbacks : [
    ['el',    'click',    'open']
  ],
  
  constructor : function(options) {
    this.base(options);
    this.content = $.el('div', {'class' : 'menu_content', id : (this.id ? this.id = '_content' : null)});
    this.modes.open = 'not';
    _.bindAll('close', this);
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
    $.align(this.content, this.el, '-left bottom', {top : 1});
    $(this.content).autohide({onHide : this.close});
  },
  
  close : function() {
    this.setMode('not', 'open');
    if (this.options.onClose) this.options.onClose(this);
    return true;
  }
  
});