dc.ui.RelatedDocumentsPanel = dc.View.extend({
  
  fragment         : null,
  searchDocumentId : null,
  page             : null,
  
  flags : {},
  
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
    this.page = page <= 1 ? null : page;
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
      this.doc.set({'selected': false}, true);
      this.doc.set({'selectable': false}, true);
      this.$el.html(JST['workspace/related_document_header']({'doc': this.doc}));
      $('.related_documents_document', this.$el).html(this.documentInHeader.render().el);
    }
  },
  
  loadRelatedDocuments : function() {
    var self = this;
    
    this.flags['showing'] = true;
    
    dc.ui.spinner.show('searching');
    _.defer(dc.app.toolbar.checkFloat);
    $(document.body).setMode('active', 'search');
    
    var params = {
      q : dc.app.searchBox.value(),
      page_size : dc.app.paginator.pageSize()
    };    

    if (dc.app.navigation.isOpen('entities')) {
      params['include_facets'] = true;
    }
    if (this.page) params['page'] = this.page;
    if (!this.doc) params['need_original_document'] = true;
    
    $.get('/search/related_documents', params, _.bind(this._renderRelatedDocuments, this), 'json');
  },
  
  showing : function() {
    return this.flags['showing'];
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

    if ('facets' in resp) {
      dc.app.workspace.organizer.renderFacets(resp.facets, 5, resp.query.total);
      Entities.refresh();
      dc.app.searchBox.flags['hasEntities'] = true;
    }
    Documents.refresh(_.map(resp.documents, function(m, i){
      m.index = i;
      return new dc.model.Document(m);
    }));
    
  },
  
  deselect : function() {
    if (this.doc) {
      this.doc.set({'selected': false});
    }
  },
  
  close : function() {
    this.doc = null;
    this.flags['showing'] = false;
    $(document.body).removeClass('related_documents');
  }

});