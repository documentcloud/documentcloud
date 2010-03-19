dc.ui.Statistics = dc.View.extend({

  GRAPH_OPTIONS : {
    xaxis     : {mode : 'time', minTickSize: [1, "day"]},
    yaxis     : {},
    legend    : {show : false},
    series    : {lines : {show : true, fill : true}, points : {show : true}},
    grid      : {borderWidth: 0, labelMargin : 7, hoverable : true, markings : false}
  },

  DATE_TRIPLETS : /(\d+)(\d{3})/,

  DATE_FORMAT : "%b %d, %y",

  id        : 'statistics',
  className : 'serif',

  callbacks : {
    '.chart.plothover': '_showTooltop'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'renderCharts');
    stats.daily_documents_series = this._series(stats.daily_documents, 'Document');
    stats.daily_pages_series = this._series(stats.daily_pages, 'Page');
    this._tooltip = new dc.ui.Tooltip();
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
    this.setCallbacks();
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

  // Create a tooltip to show a hovered date.
  _showTooltop : function(e, pos, item) {
    if (!item) return this._tooltip.hide();
    var count = item.datapoint[1];
    var date  = $.plot.formatDate(new Date(item.datapoint[0]), this.DATE_FORMAT);
    var title = Inflector.pluralize(item.series.title, count);
    this._tooltip.show({
      left : pos.pageX,
      top  : pos.pageY,
      text : count + ' ' + title + '<br />' + date
    });
  },

  // Convert a date-hash into JSON that flot can properly plot.
  _series : function(data, title) {
    return [{
      title : title,
      data : _.sortBy(_.map(data, function(val, key) {
        return [parseInt(key, 10) * 1000, val];
      }), function(pair) {
        return pair[0];
      })
    }];
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