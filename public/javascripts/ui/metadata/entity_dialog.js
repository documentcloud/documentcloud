dc.ui.EntityDialog = dc.ui.Dialog.extend({

  callbacks : {
    '.ok.click':            'close',
    '.add_to_search.click': 'addToSearch'
  },

  constructor : function(entity) {
    _.bindAll(this, '_openDocument');
    this.model = entity;
    this.base({
      mode  :     'custom',
      title :     this.model.displayTitle(),
      className : 'dialog entity_view custom_dialog'
    });
  },

  render : function() {
    this.base();
    var instances = this.model.selectedInstances();
    $('.custom', this.el).html(JST.entity_dialog({entity : this.model, instances : instances}));
    $('.controls', this.el).append($.el('button', {'class' : 'add_to_search'}, 'add to search'));
    var list = $('.document_list', this.el);
    var instances = _.sortBy(instances, function(inst) {
      return -inst.relevance;
    });
    _.each(instances, _.bind(function(inst) {
      var doc = Documents.get(inst.document_id);
      var view = (new dc.ui.Document({model : doc, noCallbacks : true})).render();
      $('.source', view.el).html('Relevance to document: ' + inst.relevance);
      $(view.el).click(_.bind(this._openDocument, this, inst, doc));
      list.append(view.el);
    }, this));
    this.center();
    this.setCallbacks();
    return this;
  },

  addToSearch : function() {
    dc.app.searchBox.addToSearch(this.model.toSearchQuery());
    this.close();
  },

  _openDocument : function(instance, doc) {
    window.open(doc.get('document_viewer_url') + "?entity=" + instance.id);
  }

});