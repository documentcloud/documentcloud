dc.ui.Paginator = dc.View.extend({

  // Keep in sync with search.rb on the server.
  PAGE_SIZE : 10,

  id        : 'paginator',
  className : 'interface',

  query : null,
  page  : null,

  callbacks : {
    '.prev.click':          'previousPage',
    '.next.click':          'nextPage',
    '.enumeration.change':  'goToPage'
  },

  constructor : function() {
    this.base();
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

  pageCount : function() {
    return Math.ceil(this.query.total / this.PAGE_SIZE);
  },

  render : function() {
    var el = $(this.el);
    el.html('');
    if (!this.query) return this;
    el.html(JST.paginator({q : this.query, page_size : this.PAGE_SIZE, page_count : this.pageCount()}));
    this.setCallbacks();
    return this;
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