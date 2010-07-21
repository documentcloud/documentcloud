dc.ui.RelatedDocumentsPanel = dc.View.extend({
  
  constructor : function(doc) {
    this.base();
    this.$el = $('#related_documents_container');
    this.doc = doc;
  },

  render : function() {
    dc.ui.spinner.show();
    $(document.body).addClass('related_documents');
    
    this.showRelatedDocumentInHeader();
    this.loadRelatedDocuments();
    
    return this;
  },
  
  showRelatedDocumentInHeader : function() {
    console.log(['showRelatedDocumentInHeader', this.$el, this.doc]);
    this.documentInHeader = (new dc.ui.Document({model : this.doc}));
    this.doc.set({'selected': false});
    this.$el.html(this.documentInHeader.render().el);
  },
  
  loadRelatedDocuments : function() {
    var self = this;
    
    dc.ui.spinner.show('searching');
    _.defer(dc.app.toolbar.checkFloat);
    // Documents.refresh();
    // dc.app.toolbar.enableToolbarButtons();
    
    var params = {
      document_id : this.doc.id, 
      page_size : dc.app.paginator.pageSize(), 
      order : dc.app.paginator.sortOrder
    };    
    if (this.page) params.page = this.page;
    
    $.get('/search/related_documents', params, _.bind(this._renderRelatedDocuments, this), 'json');
  },
  
  _renderRelatedDocuments : function(resp) {
    dc.ui.spinner.hide();
    dc.app.paginator.setQuery(resp.query);

    Documents.refresh(_.map(resp.documents, function(m, i){
      m.index = i;
      return new dc.model.Document(m);
    }));
    
    dc.app.toolbar.enableToolbarButtons();
  },
  
  deselect : function() {
    this.doc.set({'selected': false});
  },
  
  close : function() {
    $(document.body).removeClass('related_documents');
  }

});