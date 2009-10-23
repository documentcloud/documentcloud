dc.ui.Label = dc.View.extend({
  
  className : 'label box',
  
  callbacks : [
    ['el',                'click',    'showDocuments'],
    ['.delete_bullet',    'click',    'deleteLabel']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('loadDocuments', this);
    this.model.view = this;
  },
  
  render : function() {
    $(this.el).html(dc.templates.LABEL_VIEW(this.model.attributes()));
    this.setCallbacks();
    return this;
  },
  
  showDocuments : function() {
    dc.app.searchBox.search(this.model.toSearchParam());
  },
  
  deleteLabel : function(e) {
    e.stopPropagation();
    Labels.destroy(this.model);
  }
  
});
