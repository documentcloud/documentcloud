dc.ui.Label = dc.View.extend({
  
  className : 'label box',
  
  callbacks : [
    ['el',                'click',    'showDocuments'],
    ['.delete_button',    'click',    'deleteLabel']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('loadDocuments', this);
    this.model.view = this;
  },
  
  render : function() {
    $(this.el).html(JST.organizer_label(this.model.attributes()));
    this.el.id = "label_" + this.model.cid;
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
