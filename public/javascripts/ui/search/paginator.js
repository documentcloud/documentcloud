dc.ui.Paginator = Backbone.View.extend({

  DEFAULT_PAGE_SIZE : 10,
  MINI_PAGE_SIZE    : 30,

  SORT_TEXT : {
    score       : 'by relevance',
    title       : 'by title',
    created_at  : 'by date',
    source      : 'by source'
  },

  id        : 'paginator',
  className : 'interface',

  query : null,
  page  : null,
  view  : null,

  events : {
    'click .prev':                'previousPage',
    'click .next':                'nextPage',
    'click .current_placeholder': 'editPage',
    'change .current_page':       'changePage',
    'click .sorter':              'chooseSort',
    'click #size_toggle':         'toggleSize'
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
    this.setSize(dc.app.preferences.get('paginator_mini') || false);
    this.sortOrder = dc.app.preferences.get('sort_order') || 'score';
  },

  setQuery : function(query, view) {
    this.query = query;
    this.page  = query.page;
    $(document.body).addClass('paginated');
    this.render();
  },

  queryParams : function() {
    return {
      page_size : dc.app.paginator.pageSize(),
      order     : dc.app.paginator.sortOrder
    };
  },

  hide : function() {
    $(document.body).removeClass('paginated');
  },

  // Keep in sync with search.rb on the server.
  pageSize : function() {
    return this.mini ? this.MINI_PAGE_SIZE : this.DEFAULT_PAGE_SIZE;
  },

  pageFactor : function() {
    return this.mini ? this.MINI_PAGE_SIZE / this.DEFAULT_PAGE_SIZE :
                       this.DEFAULT_PAGE_SIZE / this.MINI_PAGE_SIZE;
  },

  pageCount : function() {
    return Math.ceil(this.query.total / this.pageSize());
  },

  render : function() {
    this.setMode('not', 'editing');
    var el = $(this.el);
    el.html('');
    if (!this.query) return this;
    el.html(JST['workspace/paginator']({
      q           : this.query,
      sort_text   : this.SORT_TEXT[this.sortOrder],
      page_size   : this.pageSize(),
      page_count  : this.pageCount()
    }));
    return this;
  },

  setSize : function(mini) {
    this.mini = mini;
    $(document.body).toggleClass('minidocs', this.mini);
  },

  toggleSize : function(callback, doc) {
    this.setSize(!this.mini);
    dc.app.preferences.set({paginator_mini : this.mini});
    callback = _.isFunction(callback) ? callback : null;
    var page = Math.floor(((this.page || 1) - 1) / this.pageFactor()) + 1;
    if (doc) page += Math.floor(Documents.indexOf(doc) / this.pageSize());
    dc.app.searcher.loadPage(page, callback);
  },

  chooseSort : function() {
    dc.ui.Dialog.choose('Order Documents By&hellip;', [
      {text : 'Relevance',      value : 'score',      selected : this.sortOrder == 'score'},
      {text : 'Date Uploaded',  value : 'created_at', selected : this.sortOrder == 'created_at'},
      {text : 'Title',          value : 'title',      selected : this.sortOrder == 'title'},
      {text : 'Source',         value : 'source',     selected : this.sortOrder == 'source'}
    ], _.bind(function(order) {
      this.sortOrder = order;
      dc.app.preferences.set({sort_order : order});
      this.$('.sorter').text(this.SORT_TEXT[this.sortOrder]);
      dc.app.searcher.loadPage();
      return true;
    }, this), {mode : 'short_prompt'});
  },

  editPage : function() {
    this.setMode('is', 'editing');
    this.$('.current_page').focus();
  },

  previousPage : function() {
    var page = (this.page || 1) - 1;
    dc.app.searcher.loadPage(page);
  },

  nextPage : function() {
    var page = (this.page || 1) + 1;
    dc.app.searcher.loadPage(page);
  },

  changePage : function(e) {
    var page = parseInt($(e.target).val(), 10);
    dc.app.searcher.loadPage(page);
  }

});