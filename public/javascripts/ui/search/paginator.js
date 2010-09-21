dc.ui.Paginator = dc.Controller.extend({

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

  callbacks : {
    '.prev.click':          'previousPage',
    '.next.click':          'nextPage',
    '.enumeration.change':  'changePage',
    '.sorter.click':        'chooseSort',
    '#size_toggle.click':   'toggleSize'
  },

  constructor : function() {
    this.base();
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
    var el = $(this.el);
    el.html('');
    if (!this.query) return this;
    el.html(JST['workspace/paginator']({
      q           : this.query,
      sort_text   : this.SORT_TEXT[this.sortOrder],
      page_size   : this.pageSize(),
      page_count  : this.pageCount()
    }));
    this.setCallbacks();
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
    if (doc) page += Math.floor(_.indexOf(Documents.models(), doc) / this.pageSize());
    this.goToPage(page, callback);
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
      this.goToPage();
      return true;
    }, this), {mode : 'short_prompt'});
  },

  // TODO: Move all these into the searchBox and clean it up.

  previousPage : function() {
    var page = (this.page || 1) - 1;
    this.goToPage(page);
  },

  nextPage : function() {
    var page = (this.page || 1) + 1;
    this.goToPage(page);
  },

  changePage : function(e) {
    var page = $(e.target).val();
    this.goToPage(page);
  },

  goToPage : function(page, callback) {
    page = page || this.page || 1;
    dc.app.searcher.search(dc.app.searchBox.value(), page, callback);
  }

});