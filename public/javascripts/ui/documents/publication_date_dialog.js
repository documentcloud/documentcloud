dc.ui.PublicationDateDialog = dc.ui.Dialog.extend({

  id        : 'pubdate_dialog',
  className : 'dialog',

  events : {
    'click .cancel' : 'close',
    'click .ok'     : 'save'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Set Publication Date: " + this._title();
    dc.ui.Dialog.call(this, {mode : 'custom', title : title});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    this.center();
    return this;
  },

  save : function() {
    this.close();
  },

  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + Inflector.truncate(this.docs[0].get('title'), 35) + '"';
  }

});
