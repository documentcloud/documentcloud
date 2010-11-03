dc.ui.PublicationDateDialog = dc.ui.Dialog.extend({

  id        : 'pubdate_dialog',
  className : 'dialog',

  events : {
    'click .cancel'     : 'close',
    'click .ok'         : 'save',
    'click .delete'     : 'removeDate',
    'click .public_now' : 'editAccess'
  },

  constructor : function(docs) {
    this.docs = docs;
    this.multiple = docs.length > 1;
    var title = "Set Publication Date for " + this._title();
    dc.ui.Dialog.call(this, {
      mode        : 'custom',
      title       : title,
      editor      : true,
      closeText   : "Cancel",
      deleteText  : "Remove"
    });
    this.render();
    $(document.body).append(this.el);
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    var publishAt = Documents.sharedAttribute(this.docs, 'publish_at');
    var oneHour = 60 * 60 * 1000;
    this._container.html(JST['document/publication_date_dialog']({
      multiple: this.multiple,
      date:     publishAt ? DateUtils.parseRfc(publishAt) : new Date(+(new Date) + oneHour)
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

  editAccess : function() {
    this.close();
    Documents.editAccess(this.docs);
  },

  save : function() {
    var date = this.getDate();
    if (date < new Date) {
      this.close();
      dc.ui.Dialog.alert("You can't set a document to be published in the past.");
      return;
    }
    var utc = JSON.stringify(date);
    _.each(this.docs, function(doc){ doc.save({publish_at : utc}); });
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
