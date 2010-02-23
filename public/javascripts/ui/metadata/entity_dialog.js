dc.ui.EntityDialog = dc.ui.Dialog.extend({

  callbacks : {
    '.ok.click': 'confirm'
  },

  constructor : function(entity) {
    this.model = entity;
    this.base({
      mode  :     'custom',
      title :     this.model.displayTitle(),
      className : 'dialog entity_view custom_dialog'
    });
  },

  render : function() {
    this.base();
    $('.custom', this.el).html(JST.entity_dialog({entity : this.model}));
    $('button.cancel', this.el).remove();
    var list = $('.document_list', this.el);
    _.each(this.model.get('instances'), function(inst) {
      var doc = Documents.get(inst.document_id);
      var view = (new dc.ui.Document({model : doc, noCallbacks : true})).render();
      $(view.el).click(function(){ alert('hi'); });
      list.append(view.el);
    });
    this.center();
    this.setCallbacks();
    return this;
  }

});