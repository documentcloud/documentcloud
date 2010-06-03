dc.ui.EmbedDialog = dc.ui.Dialog.extend({

  className : 'dialog embed_code',

  callbacks : {
    '.ok.click'       : 'close',
    '.snippet.click'  : 'selectSnippet'
  },

  constructor : function(doc) {
    this.doc = doc;
    this.base({
      mode      : 'custom',
      title     : 'Embed Code for "' + doc.get('title') + '"'
    });
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    this.base();
    this._container = $('.custom', this.el);
    this._container.html(JST.embed_dialog({doc : this.doc}));
    this.setCallbacks();
    return this;
  },

  selectSnippet : function() {
    $('.snippet', this.el).select();
  }

});
