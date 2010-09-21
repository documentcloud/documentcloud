dc.ui.DocumentDialog = dc.ui.Dialog.extend({

  ATTRIBUTES : ['title', 'source', 'description', 'related_article', 'remote_url', 'access'],

  id        : 'edit_document_dialog',
  className : 'dialog docalog',

  callbacks : {
    '.cancel.click'     : 'close',
    '.ok.click'         : 'save',
    'input.focus'       : '_addFocus',
    'textarea.focus'    : '_addFocus',
    'input.blur'        : '_removeFocus',
    'textarea.blur'     : '_removeFocus',
    '.delete.click'     : 'destroy',
    '.attribute.change' : '_markChanged'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Edit " + this._title();
    this.base({mode : 'custom', title : title, editor : true});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    this.base();
    this._container = this.$('.custom');
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
      var el = this.$('#document_edit_' + attr);
      if (!el.length) return;
      var next = el.val();
      if (attr == 'access') next = parseInt(next, 10);
      if (attr == 'related_article' || attr == 'remote_url') next = Inflector.normalizeUrl(next);
      if (next != original[attr] && el.hasClass('changed')) changes[attr] = next;
    }, this));
    var errors = _.any(['related_article', 'remote_url'], _.bind(function(attr) {
      if (changes[attr] && !this.validateUrl(changes[attr])) {
        this.$('#document_edit_' + attr).addClass('error');
        return true;
      }
    }, this));
    if (errors) return false;
    this.close();
    if (!_.isEmpty(changes)) {
      _.each(this.docs, function(doc){ Documents.update(doc, changes); });
      dc.ui.notifier.show({mode : 'info', text : 'Updated ' + this.docs.length + ' ' + Inflector.pluralize('document', this.docs.length)});
    }
  },

  destroy : function() {
    this.close();
    if (Documents.selected().length == 0) {
      this.docs[0].set({'selected': true});
    }
    Documents.verifyDestroy(Documents.selected());
  },

  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + Inflector.truncate(this.docs[0].get('title'), 35) + '"';
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
    var docs = Documents.chosen(doc);
    if (!docs.length) return;
    if (!Documents.allowedToEdit(docs)) return;
    new dc.ui.DocumentDialog(docs);
  }

});
