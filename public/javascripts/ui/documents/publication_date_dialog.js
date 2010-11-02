dc.ui.PublicationDateDialog = dc.ui.Dialog.extend({

  id        : 'pubdate_dialog',
  className : 'dialog',

  events : {
    'click .cancel' : 'close',
    'click .ok'     : 'save',
    'click .delete' : 'removeDate'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Set Publication Date for " + this._title();
    dc.ui.Dialog.call(this, {
      mode        : 'custom',
      title       : title,
      editor      : true,
      deleteText  : "Remove"
    });
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    var publishAt = Documents.sharedAttribute(this.docs, 'publish_at');
    this._container.html(JST['document/publication_date_dialog']({
      multiple: this.multiple,
      date:     publishAt ? DateUtils.parseRfc(publishAt) : new Date
    }));
    this.center();
    return this;
  },

  getDate : function() {
    return new Date(
      this.$('.date_year').val(),
      parseInt(this.$('.date_month').val(), 10) - 1,
      this.$('.date_day').val(),
      this.$('.date_hour').val()
    );
  },

  save : function() {
    var date = JSON.stringify(this.getDate());
    _.each(this.docs, function(doc){ doc.save({publish_at : date}); });
    this.close();
  },

  removeDate : function() {
    _.each(this.docs, function(doc){ doc.save({publish_at : null}); });
    this.close();
  },

  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + Inflector.truncate(this.docs[0].get('title'), 35) + '"';
  }

});
