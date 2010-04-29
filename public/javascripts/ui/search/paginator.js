dc.ui.Paginator = dc.View.extend({

  // Keep in sync with search.rb on the server.
  PAGE_SIZE : 10,

  id        : 'paginator',
  className : 'gradient_white',

  query : null,
  page  : null,

  callbacks : {
    '.previous_page.click': 'previousPage',
    '.next_page.click':     'nextPage',
    '.page_link.click':     'goToPage'
  },

  constructor : function() {
    this.base();
    this.prevEl   = $.el('span', {'class' : 'arrow previous_page'}, '&laquo; Previous');
    this.nextEl   = $.el('span', {'class' : 'arrow next_page'}, 'Next &raquo;');
  },

  setQuery : function(query) {
    this.query = query;
    this.page  = query.page;
    $(document.body).toggleClass('paginated', this.active());
    this.render();
  },

  hide : function() {
    $(document.body).removeClass('paginated');
  },

  pageCount : function() {
    return Math.ceil(this.query.total / this.PAGE_SIZE);
  },

  // Do we have more results than we can display on a single page?
  active : function() {
    return this.query && this.query.total > this.PAGE_SIZE;
  },

  render : function() {
    var el = $(this.el);
    el.html('');
    if (!this.active()) return this;
    var from = this.query.from, to = this.query.to;
    links = [];
    links.push($.el('span', {'class' : 'description'}, this.sentence()));
    var start = this.page > 5 ? this.page - 5 : 1;
    var end   = start + 9 > this.pageCount() ? this.pageCount() : start + 9;
    if (from > 0) links.push(this.prevEl);
    for (var i=start; i<=end; i++) {
      var pageLink = $.el('span', {'class' : 'page_link ' + (i == this.page ? ' current' : '')}, i);
      pageLink.page = i;
      links.push(pageLink);
    }
    if (to < this.query.total) links.push(this.nextEl);
    el.append(links);
    this.setCallbacks();
    return this;
  },

  // Generate the sentence about our location within the page ranges.
  sentence : function() {
    var q         = this.query;
    var to        = Math.min(q.to, q.total);
    // var pagePart  = "Page " + this.page + ': ';
    var fromPart  = (q.total < 2 ? '' : '' + (q.from + 1) + " &ndash; " + to + " of");
    var docPart   = Inflector.pluralize('document', q.total);
    var sentence  = [fromPart, q.total, docPart].join(' ');
    return sentence;
  },

  // TODO: Move all these into the searchBox and clean it up.

  previousPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (this.page || 1) - 1);
  },

  nextPage : function() {
    dc.app.searchBox.search(dc.app.searchBox.value(), (this.page || 1) + 1);
  },

  goToPage : function(e) {
    dc.app.searchBox.search(dc.app.searchBox.value(), e.target.page);
  }

});