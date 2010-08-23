dc.ui.Publish = dc.View.extend({
  
  callbacks : {},
  
  constructor : function() {
    dc.app.publishPreview = new dc.ui.PublishPreview();
  },
  
  render : function() {
    this.el = $('#publish_container')[0];
    dc.history.register(/^#publish$/,    _.bind(this.openPublishTab, this));
    dc.history.register(/^#publish\//,     _.bind(this.openDocumentInHash, this));
    dc.app.navigation.bind('tab:publish',  _.bind(this.openPublishTab, this));
    this.setCallbacks();
    return this;
  },
  
  openPublishTab : function() {
    dc.app.navigation.open('publish');
    dc.history.save('publish');
  },
  
  openDocumentInHash : function(hash) {
    var docId = parseInt(dc.app.SearchParser.extractSpecificDocId('docid: ' + hash), 10);
    dc.app.searcher.searchByHash('docid: ' + docId, _.bind(function() {
      var doc = Documents.get(docId);
      this.renderDocumentPreview(doc);
    }, this));
  },
  
  renderDocumentPreview : function(doc) {
    this.openPublishTab();
    console.log(['renderDocumentPreview', doc]);
    dc.app.publishPreview.render(doc);
  }
  
});