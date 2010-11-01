dc.ui.PublicationDateDialog = dc.ui.Dialog.extend({

  id        : 'pubdate_dialog',
  className : 'dialog',

  events : {
    'click .cancel' : 'close',
    'click .ok'     : 'save'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Set Publication Date for " + this._title();
    dc.ui.Dialog.call(this, {mode : 'custom', title : title, saveText : 'Save'});
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    this._container.html(JST['document/publication_date_dialog']());
    this.center();
    return this;
  },

  getDate : function() {
    return new Date(
      this.$('#date_year').val(),
      parseInt(this.$('#date_month').val(), 10) - 1,
      this.$('#date_day').val(),
      this.$('#date_hour').val()
    );
  },

  save : function() {
    var date = this.getDate();
    _.each(this.docs, function(doc){ doc.save({publish_at : date}); });
    this.close();
  },

  _title : function() {
    if (this.multiple) return this.docs.length + ' Documents';
    return '"' + Inflector.truncate(this.docs[0].get('title'), 35) + '"';
  }

});
