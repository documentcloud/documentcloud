dc.ui.Label = dc.View.extend({
  
  className : 'label',
  
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
    if (!this.model.get('document_ids')) return;
    dc.history.save('label/' + encodeURIComponent(this.model.get('title')));
    dc.ui.spinner.show('loading documents');
    $.get('/labels/documents/' + this.model.id + '.json', {}, this.loadDocuments, 'json');
  },
  
  loadDocuments : function(resp) {
    dc.ui.spinner.hide();
    dc.app.LabeledDocuments.refresh(_.map(resp.documents, function(m){
      return new dc.model.Document(m);
    }));
    var list = new dc.ui.DocumentList({set : dc.app.LabeledDocuments});
    list.setMode('medium', 'size');
    $('#labeled_documents_container').html(list.render().el);
    dc.app.LabeledDocuments.each(function(doc) {
      $('#labeled_documents_container .documents').append((new dc.ui.DocumentTile(doc)).render().el);
    });
  },
  
  deleteLabel : function(e) {
    e.stopPropagation();
    Labels.destroy(this.model);
  }
  
});
