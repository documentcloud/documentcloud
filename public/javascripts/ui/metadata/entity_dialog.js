dc.ui.EntityDialog = dc.ui.Dialog.extend({

  className : 'entity_dialog',

  callbacks : {
    '.ok.click': 'confirm'
  },

  constructor : function(entity) {
    this.model = entity;
    this.base({
      mode      : 'custom',
      title     : this.displayTitle()
    });
    // dc.ui.spinner.show();
    // this._loadPages();
  },

  render : function() {
    this.base();
    // $('.custom', this.el).append(this.plot);
    $(this.el).align($('#content')[0] || document.body, null, {top : -100});
    this.setCallbacks();
    return this;
  },

  displayTitle : function() {
    return "An Entity";
  }

});