dc.ui.DocumentDialog = dc.ui.Dialog.extend({

  ATTRIBUTES : ['title', 'source', 'description', 'related_article', 'access'],

  id        : 'edit_document_dialog',
  className : 'dialog docalog',

  callbacks : {
    '.cancel.click'     : 'close',
    '.ok.click'         : 'save',
    '.delete.click'     : 'destroy',
    '.attribute.change' : '_markChanged'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Edit " + (this.multiple ? docs.length + ' Documents' : '"' + docs[0].get('title') + '"');
    this.base({mode : 'custom', title : title, editor : true});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    this.base();
    this._container = $('.custom', this.el);
    this._container.html(JST['document/document_dialog']({
      docs : this.docs, multiple : this.multiple
    }));
    var attrs = this._sharedAttributes();
    attrs['access'] = attrs['access'] || dc.access.PRIVATE;
    _.each(this.ATTRIBUTES, _.bind(function(attr) {
      $('#document_edit_' + attr).val(attrs[attr] || '');
    }, this));
    this.center();
    return this;
  },

  save : function() {
    var original = this._sharedAttributes();
    var changes = {};
    _.each(this.ATTRIBUTES, _.bind(function(attr) {
      var el = $('#document_edit_' + attr, this.el);
      var next = el.val();
      if (attr == 'access') next = parseInt(next, 10);
      if (next != original[attr] && el.hasClass('changed')) changes[attr] = next;
    }, this));
    this.close();
    if (!_.isEmpty(changes)) {
      _.each(this.docs, function(doc){ Documents.update(doc, changes); });
      dc.ui.notifier.show({mode : 'info', text : 'Updated ' + this.docs.length + ' ' + Inflector.pluralize('document', this.docs.length)});
    }
  },

  destroy : function() {
    this.close();
    Documents.destroySelected();
  },

  _markChanged : function(e) {
    $(e.target).addClass('changed');
  },

  _sharedAttributes : function() {
    return _.reduce(this.ATTRIBUTES, _.bind(function(memo, attr) {
      memo[attr] = Documents.sharedAttribute(this.docs, attr);
      return memo;
    }, this), {});
  }

}, {

  open : function(doc) {
    var docs = Documents.selected();
    docs = !doc || _.include(docs, doc) ? docs : [doc];
    new dc.ui.DocumentDialog(docs);
  }

});
