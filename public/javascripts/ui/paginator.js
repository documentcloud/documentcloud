dc.ui.Paginator = dc.View.extend({
    
  id : 'paginator',
  
  PAGE_SIZE : 10,
  
  callbacks : [
    ['.previous_page',    'click',    'previousPage'],
    ['.next_page',        'click',    'nextPage'],
    ['.page_link',        'click',    'goToPage']
  ],
  
  constructor : function(query) {
    this.base();
    this.query = query;
    this.prevEl = $.el('span', {'class' : 'arrow previous_page'}, '&larr;');
    this.nextEl = $.el('span', {'class' : 'arrow next_page'}, '&rarr;');
  },
  
  pageCount : function() {
    return Math.ceil(this.query.total / this.PAGE_SIZE);
  },
    
  render : function() {
    var el = $(this.el);
    el.html('');
    if (this.query.total < this.PAGE_SIZE) return this;
    var from = this.query.from, to = this.query.to;
    if (from > 0) el.append(this.prevEl);
    for (var i=1; i<=this.pageCount(); i++) {
      var current = (from >= (i-1) * this.PAGE_SIZE && from < i * this.PAGE_SIZE);
      var pageLink = $.el('span', {'class' : 'page_link' + (current ? ' current' : '')}, i);
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