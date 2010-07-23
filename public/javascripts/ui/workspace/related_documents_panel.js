dc.ui.RelatedDocumentsPanel = dc.View.extend({
  
  fragment      : null,
  searchDocumentId : null,
  page : 1,
  
  constructor : function(options) {
    this.base(options);
  },

  render : function(doc) {
    this.$el = $('#related_documents_container');
    this.doc = doc;
    dc.ui.spinner.show();
    $(document.body).addClass('related_documents');
    
    Projects.deselectAll();
    this.showRelatedDocumentInHeader();
    this.loadRelatedDocuments();
    
    return this;
  },
  
  search : function(query, page, callback) {
    var relatedDocumentId = parseInt(dc.app.SearchParser.extractRelatedDocumentId(query), 10);
    var doc = Documents.get(relatedDocumentId);
    this.page = page || this.page;
    this.searchDocumentId = relatedDocumentId;
    this.fragment = 'search/' + encodeURIComponent(query);
    this.render(doc);
    dc.history.save(this.urlFragment());
  },
  
  urlFragment : function() {
    return this.fragment + (this.page ? '/p' + this.page : '');
  },
  
  showRelatedDocumentInHeader : function() {
    if (this.doc) {
      this.documentInHeader = new dc.ui.Document({model : this.doc});
      this.doc.set({'selected': false});
      this.$el.html(this.documentInHeader.render().el);
    }
  },
  
  loadRelatedDocuments : function() {
    var self = this;
    
    dc.ui.spinner.show('searching');
    _.defer(dc.app.toolbar.checkFloat);
    $(document.body).setMode('active', 'search');
    // Documents.refresh();
    // dc.app.toolbar.enableToolbarButtons();
    
    this.page = this.page <= 1 ? null : this.page;
    
    var params = {
      document_id : this._documentId(),
      page_size : dc.app.paginator.pageSize()
    };    

    if (this.page) params['page'] = this.page;
    if (!this.doc) params['need_original_document'] = true;
    
    $.get('/search/related_documents', params, _.bind(this._renderRelatedDocuments, this), 'json');
  },
  
  _documentId : function() {
    if (this.doc) {
      return this.doc.id;
    } else if (this.searchDocumentId) {
      return this.searchDocumentId;
    }
  },
  
  _renderRelatedDocuments : function(resp) {
    dc.ui.spinner.hide();
    dc.app.paginator.setQuery(resp.query, this);
    
    if (!this.doc && 'original_document' in resp) {
      this.doc = new dc.model.Document(resp['original_document']);
      this.showRelatedDocumentInHeader();
    }

    Documents.refresh(_.map(resp.documents, function(m, i){
      m.index = i;
      return new dc.model.Document(m);
    }));
    
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