dc.ui.Statistics = dc.View.extend({

  GRAPH_OPTIONS : {
    xaxis     : {mode : 'time', minTickSize: [1, "day"]},
    yaxis     : {},
    legend    : {show : false},
    series    : {lines : {show : true, fill : true}, points : {show : true}},
    grid      : {borderWidth: 0, labelMargin : 7, hoverable : true, markings : false}
  },

  DATE_TRIPLETS : /(\d+)(\d{3})/,

  id        : 'statistics',
  className : 'serif',

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'renderCharts');
    stats.daily_documents_series = this._series(stats.daily_documents);
    stats.daily_pages_series = this._series(stats.daily_pages);
    $(window).bind('resize', this.renderCharts);
  },

  render : function() {
    var data = {
      total_documents       : this._format(this.totalDocuments()),
      total_pages           : this._format(stats.total_pages),
      average_page_count    : this._format(stats.average_page_count),
      average_entity_count  : this._format(stats.average_entity_count)
    };
    $(this.el).html(JST.statistics(data));
    _.defer(this.renderCharts);
    return this;
  },

  renderCharts : function() {
    $('.chart', this.el).html('');
    $.plot($('#docs_uploaded_chart'), stats.daily_documents_series, this.GRAPH_OPTIONS);
    $.plot($('#pages_uploaded_chart'), stats.daily_pages_series, this.GRAPH_OPTIONS);
    console.log($('#docs_uploaded_chart').width(), $('#docs_uploaded_chart canvas').width());
  },

  totalDocuments : function() {
    return _.reduce(stats.documents_by_access, 0, function(sum, value) {
      return sum + value;
    });
  },

  // Convert a date-hash into JSON that flot can properly plot.
  _series : function(data) {
    return [_.sortBy(_.map(data, function(val, key) {
      return [parseInt(key, 10) * 1000, val];
    }), function(pair) {
      return pair[0];
    })];
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