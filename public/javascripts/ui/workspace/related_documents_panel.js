dc.ui.RelatedDocumentsPanel = dc.View.extend({
  
  constructor : function(options) {
    this.base(options);
  },

  render : function(doc) {
    this.$el = $('#related_documents_container');
    this.doc = doc;
    dc.ui.spinner.show();
    $(document.body).addClass('related_documents');
    
    this.showRelatedDocumentInHeader();
    this.loadRelatedDocuments(1);
    
    return this;
  },
  
  showRelatedDocumentInHeader : function() {
    this.documentInHeader = new dc.ui.Document({model : this.doc});
    this.doc.set({'selected': false});
    this.$el.html(this.documentInHeader.render().el);
  },
  
  loadRelatedDocuments : function(page) {
    var self = this;
    
    dc.ui.spinner.show('searching');
    _.defer(dc.app.toolbar.checkFloat);
    // Documents.refresh();
    // dc.app.toolbar.enableToolbarButtons();
    
    var params = {
      document_id : this.doc.id, 
      page_size : dc.app.paginator.pageSize(), 
      order : dc.app.paginator.sortOrder,
      page : page
    };    
    
    $.get('/search/related_documents', params, _.bind(this._renderRelatedDocuments, this), 'json');
  },
  
  _renderRelatedDocuments : function(resp) {
    dc.ui.spinner.hide();
    dc.app.paginator.setQuery(resp.query, this);

    Documents.refresh(_.map(resp.documents, function(m, i){
      m.index = i;
      return new dc.model.Document(m);
    }));
    
    Documents.add(this.documentInHeader);
    
    dc.app.toolbar.enableToolbarButtons();
  },
  
  deselect : function() {
    if (this.doc) {
      this.doc.set({'selected': false});
    }
  },
  
  close : function() {
    this.doc = null;
    $(document.body).removeClass('related_documents');
  }

});