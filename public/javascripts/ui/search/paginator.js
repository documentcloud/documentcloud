dc.ui.Paginator = dc.View.extend({

  DEFAULT_PAGE_SIZE : 10,
  MINI_PAGE_SIZE    : 30,

  id        : 'paginator',
  className : 'interface',

  query : null,
  page  : null,

  callbacks : {
    '.prev.click':          'previousPage',
    '.next.click':          'nextPage',
    '.enumeration.change':  'goToPage',
    '#size_toggle.click':   'toggleSize'
  },

  constructor : function() {
    this.base();
    this.mini = false;
  },

  setQuery : function(query) {
    this.query = query;
    this.page  = query.page;
    $(document.body).addClass('paginated');
    this.render();
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
    el.html(JST.paginator({q : this.query, page_size : this.pageSize(), page_count : this.pageCount()}));
    this.setCallbacks();
    return this;
  },

  toggleSize: function(callback) {
    this.mini = !this.mini;
    callback = _.isFunction(callback) ? callback : null;
    var page = Math.floor(((this.page || 1) - 1) / this.pageFactor()) + 1;
    dc.app.searchBox.search(dc.app.searchBox.value(), page, callback);
    $(document.body).toggleClass('minidocs', this.mini);
  },

  // TODO: Move all these into the searchBox and clean it up.

  previousPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (this.page || 1) - 1);
  },

  nextPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (this.page || 1) + 1);
  },

  goToPage : function(e) {
    dc.app.searchBox.search(dc.app.searchBox.value(), $(e.target).val());
  }

});