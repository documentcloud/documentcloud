dc.ui.Label = dc.View.extend({
  
  className : 'label',
  
  callbacks : [],
  
  constructor : function(options) {
    this.base(options);
    this.model.view = this;
  },
  
  render : function() {
    $(this.el).html(dc.templates.LABEL_VIEW(this.model.attributes()));
    this.setCallbacks();
    return this;
  }
  
});
