dc.ui.Paginator = dc.View.extend({

  PAGE_SIZE : 10,

  id    : 'paginator',
  query : null,
  page  : null,

  callbacks : [
    ['.previous_page',    'click',    'previousPage'],
    ['.next_page',        'click',    'nextPage'],
    ['.page_link',        'click',    'goToPage']
  ],

  constructor : function() {
    this.base();
    this.prevEl   = $.el('span', {'class' : 'arrow previous_page'}, '&larr;');
    this.nextEl   = $.el('span', {'class' : 'arrow next_page'}, '&rarr;');
  },

  setQuery : function(query) {
    this.query = query;
    this.page = Math.floor(query.from / this.PAGE_SIZE) + 1;
    this.render();
  },

  pageCount : function() {
    return Math.ceil(this.query.total / this.PAGE_SIZE);
  },

  render : function() {
    var el = $(this.el);
    el.html('');
    if (!this.query || this.query.total <= this.PAGE_SIZE) return this;
    el.html('page: ');
    var from = this.query.from, to = this.query.to;
    if (from > 0) el.append(this.prevEl);
    for (var i=1; i<=this.pageCount(); i++) {
      var pageLink = $.el('span', {'class' : 'page_link' + (i == this.page ? ' current' : '')}, i);
      pageLink.page = i;
      el.append(pageLink);
    }
    if (to < this.query.total) el.append(this.nextEl);
    this.setCallbacks();
    return this;
  },

  // TODO: Move all these into the searchBox and clean it up.

  previousPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (dc.app.searchBox.currentPage || 1) - 1);
  },

  nextPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (dc.app.searchBox.currentPage || 1) + 1);
  },

  goToPage : function(e) {
    dc.app.searchBox.search(dc.app.searchBox.value(), e.target.page);
  }

});