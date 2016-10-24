dc.ui.AdminStatistics = Backbone.View.extend({

  GRAPH_OPTIONS : {
    xaxis     : {mode : 'time', minTickSize: [1, "day"]},
    yaxis     : {},
    legend    : {show : false},
    series    : {lines : {show : true, fill : false}, points : {show : false}},
    grid      : {borderWidth: 1, borderColor: '#222', labelMargin : 7, hoverable : true}
  },

  DATE_TRIPLETS : /(\d+)(\d{3})/,

  DATE_FORMAT : "%b %d, %y",

  // Quick tags for the instances we know about. Purely for convenience.
  INSTANCE_TAGS : {
    'i-21bbe0c0': 'staging',
    'i-5512ccb9': 'app01',
    'i-ed2a2cbd': 'db01',
    'i-0fa8af25': 'solr01',
    'i-4e593ae2': 'worker01',
    'i-4f593ae3': 'worker02',
    'i-48593ae4': 'worker03',
    'i-3e65c9c0': 'worker04',
    'i-49593ae5': 'worker05',
    'i-4a593ae6': 'worker06'
  },

  id        : 'statistics',
  className : 'serif',

  events : {
    'plothover .chart':           '_showTooltop',
    'click #instances .minus':    '_terminateInstance',
    'click .more_top_documents':  '_loadMoreTopDocuments',
    'click #load_all_accounts':   '_loadAllAccounts',
    'click .account_list .sort':  '_sortAccounts'
  },

  ACCOUNT_COMPARATORS : {
    name           : dc.model.AccountSet.prototype.comparator,
    email          : function(account){ return account.get('email').toLowerCase(); },
    organization   : function(account){ return account.get('orgnization_name').toLowerCase(); },
    document_count : function(account){ return -(account.get('public_document_count') || 0 + account.get('private_document_count') || 0); },
    page_count     : function(account){ return -account.get('page_count') || 0; }
  },

  initialize : function(options) {
    _.bindAll(this, 'renderCharts', '_loadAllAccounts');
    this._tooltip = new dc.ui.Tooltip();
    $(window).bind('resize', this.renderCharts);
  },

  render : function() {
    $(this.el).html(JST['statistics'](this.data()));
    _.defer(this.renderCharts);
    if (Accounts.length) _.defer(this._loadAllAccounts);

    return this;
  },

  renderCharts : function() {
    this.$('.chart').html('');
    $.plot($('#daily_docs_chart'),  [this._series(stats.daily_documents, 'Document', 1), this._series(stats.daily_pages, 'Page', 2)], this.GRAPH_OPTIONS);
    $.plot($('#weekly_docs_chart'), [this._series(stats.weekly_documents, 'Document', 1), this._series(stats.weekly_pages, 'Page', 2)], this.GRAPH_OPTIONS);
    $.plot($('#daily_hits_chart'),  [this._series(stats.daily_hits_on_documents, 'Document Hit'), this._series(stats.daily_hits_on_notes, 'Note Hit'), this._series(stats.daily_hits_on_searches, 'Search Hit')], this.GRAPH_OPTIONS);
    $.plot($('#weekly_hits_chart'), [this._series(stats.weekly_hits_on_documents, 'Document Hit'), this._series(stats.weekly_hits_on_notes, 'Note Hit'), this._series(stats.weekly_hits_on_searches, 'Search Hit')], this.GRAPH_OPTIONS);
  },

  // Convert a date-hash into JSON that flot can properly plot.
  _series : function(data, title, axis) {
    return {
      title : title,
      yaxis : axis,
      color : axis == 1 ? '#7EC6FE' : '#199aff',
      data  : _.sortBy(_.map(data, function(val, key) {
        return [parseInt(key, 10) * 1000, val];
      }), function(pair) {
        return pair[0];
      })
    };
  },

  renderAccounts : function() {
    this.$('#accounts_wrapper').html((new dc.ui.AdminAccounts()).render().el);
  },

  data : function() {
    var acl = stats.documents_by_access, a = dc.access;
    return {
      total_documents               : this._format(this.totalDocuments()),
      embedded_documents            : this._format(stats.embedded_documents),
      total_pages                   : this._format(stats.total_pages),
      average_page_count            : this._format(stats.average_page_count),
      public_docs                   : this._format(acl[a.PUBLIC] || 0),
      private_docs                  : this._format((acl[a.PRIVATE] || 0) + (acl[a.ORGANIZATION] || 0) + (acl[a.EXCLUSIVE] || 0)),
      pending_docs                  : this._format(acl[a.PENDING] || 0),
      error_docs                    : this._format(acl[a.ERROR] || 0),
      instance_tags                 : this.INSTANCE_TAGS,
      remote_url_hits_last_week     : this._format(stats.remote_url_hits_last_week),
      remote_url_hits_all_time      : this._format(stats.remote_url_hits_all_time),
      count_organizations_embedding : this._format(stats.count_organizations_embedding),
      count_total_collaborators     : this._format(stats.count_total_collaborators)

    };
  },

  totalDocuments : function() {
    return _.reduce(stats.documents_by_access, function(sum, value) {
      return sum + value;
    }, 0);
  },

  _terminateInstance : function(e) {
    var instanceId = $(e.target).attr('data-id');
    dc.ui.Dialog.confirm('Are you sure you want to terminate instance <b>' + instanceId + '</b>?', function() {
      $.post('/admin/terminate_instance', {instance: instanceId}, function() {
        dc.ui.Dialog.alert('Instance <b>' + instanceId + '</b> is shutting down.');
      });
      return true;
    });
  },

  _sortAccounts : function(e) {
    var sort = $(e.target).attr('data-sort');
    Accounts.comparator = this.ACCOUNT_COMPARATORS[sort];
    Accounts.sort();
    this.renderAccounts();
    $('.account_list .sort_' + sort).addClass('active');
  },

  // Create a tooltip to show a hovered date.
  _showTooltop : function(e, pos, item) {
    if (!item) return this._tooltip.hide();
    var count = item.datapoint[1];
    var date  = $.plot.formatDate(new Date(item.datapoint[0]), this.DATE_FORMAT);
    var title = dc.inflector.pluralize(item.series.title, count);
    this._tooltip.show({
      left : pos.pageX,
      top  : pos.pageY,
      title: count + ' ' + title,
      text : date
    });
  },

  _loadAllAccounts : function() {
    $('#load_all_accounts').hide();
    $('.minibutton.download_csv').hide();
    var finish = _.bind(function() {
      this.renderAccounts();
      this._addCountsToAccounts();
      $('tr.accounts_row').show();
    }, this);
    if (Accounts.length) return finish();
    $.getJSON('/admin/all_accounts', {}, _.bind(function(resp) {
      Accounts.reset(resp.accounts);
      delete resp.accounts;
      _.extend(stats, resp);
      finish();
    }, this));
  },

  // Loads the top 100 published documents, sorted by number of hits in the past year.
  _loadMoreTopDocuments : function(e) {
    $.getJSON('/admin/hits_on_documents', {}, _.bind(this._displayMoreTopDocuments, this));
  },

  // Displays all top documents, retrieved through AJAX.
  _displayMoreTopDocuments : function(data) {
    TopDocuments.reset(data);
    this.$('.top_documents_list').replaceWith(JST['top_documents']({}));
    this.$('.top_documents_label_year').css({'display': 'table-row'});
    this.$('.top_documents_label_week').css({'display': 'none'});
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
  },

  _addCountsToAccounts : function() {
    Accounts.each(function(acc) {
      acc.set({
        public_document_count   : stats.public_per_account[acc.id],
        private_document_count  : stats.private_per_account[acc.id],
        page_count              : stats.pages_per_account[acc.id]
      });
    });
  }

});
