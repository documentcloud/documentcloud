dc.ui.Statistics = dc.View.extend({

  DATE_TRIPLETS : /(\d+)(\d{3})/,

  id        : 'statistics',
  className : 'serif',

  render : function() {
    var data = {
      total_documents       : this._format(this.totalDocuments()),
      total_pages           : this._format(stats.total_pages),
      average_page_count    : this._format(stats.average_page_count),
      average_entity_count  : this._format(stats.average_entity_count)
    };
    $(this.el).html(JST.statistics(data));
    return this;
  },

  totalDocuments : function() {
    return _.reduce(stats.documents_by_access, 0, function(sum, value) {
      return sum + value;
    });
  },

  // Format a number by adding commas in all the right places.
  _format : function(number) {
    var parts = (number + '').split('.');
    var integer = parts[0];
    var decimal = parts.length > 1 ? '.' + parts[1] : '';
    while (this.DATE_TRIPLETS.test(integer)) {
      integer = integer.replace(this.DATE_TRIPLETS, '$1,$2');
    }
    return integer + decimal;
  }

});