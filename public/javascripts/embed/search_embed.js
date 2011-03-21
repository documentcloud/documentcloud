window.dc = window.dc || {};
window.dc.embed = window.dc.embed || {};
  
dc.loadSearchEmbed = function(searchUrl, opts) {
  var id = Inflector.sluggify(opts.originalQuery || opts.q);
  
  dc.embed[id] = dc.embed[id] || {};
  dc.embed[id].options = opts = _.extend({}, {
    searchUrl     : searchUrl,
    originalQuery : opts.originalQuery || opts.q,
    per_page      : 12,
    order         : 'score',
    search_bar    : true,
    page          : 1,
    title         : null
  }, opts);
  
  var api = {
    q              : opts.q,
    per_page       : opts.per_page,
    order          : opts.order,
    page           : opts.page
  };
  var params = [
    encodeURIComponent(api.q),
    '/p-',
    encodeURIComponent(api.page),
    '-per-',
    encodeURIComponent(api.per_page),
    '-order-',
    encodeURIComponent(api.order),
    '.js'
  ].join('');
  $.getScript(searchUrl + params);
};

dc.loadSearchEmbedCallback = function(json) {
  var searchQuery = Inflector.sluggify(json.query);
  var id = _.detect(_.keys(dc.embed), function(q) {
    if (searchQuery.indexOf(q) == 0) {
      return true;
    }
  });
  _.extend(dc.embed[id].options, {
    id       : id,
    total    : json.total,
    per_page : json.per_page,
    page     : json.page,
    dc_url   : json.dc_url
  });
  
  if (dc.embed[id].isLoaded) {
    dc.embed[id].documents.refresh(json.documents);
  } else {
    dc.embed[id].documents       = new dc.EmbedDocumentSet(json.documents, dc.embed[id].options);
    dc.embed[id].workspace       = new dc.EmbedWorkspaceView(dc.embed[id].options);
    dc.embed[id].originalOptions = _.clone(dc.embed[id].options);
    dc.embed[id].isLoaded        = true;
  }
  
};

dc.EmbedDocument = Backbone.Model.extend({

  url : function() {
    return this.get('resources').published_url || this.get('canonical_url');
  },
  
  isPrivate : function() {
    return this.get('access') == 'organization' || this.get('access') == 'private';
  }
  
});

dc.EmbedDocumentSet = Backbone.Collection.extend({

  model : dc.EmbedDocument,
  
  initialize : function(models) {
    this.originalModels = models;
  }

});

dc.EmbedWorkspaceView = Backbone.View.extend({
  
  className : 'DC-search-embed',
  
  events : {
    'click    .DC-cancel-search' : 'cancelSearch',
    'click    .DC-arrow-right'   : 'nextPage',
    'click    .DC-arrow-left'    : 'previousPage',
    'click    .DC-page-current'  : 'editPage',
    'change   .DC-page-edit'     : 'changePage',
    'keypress .DC-search-box'    : 'maybePerformSearch'
  },
  
  initialize : function() {
    this.embed     = dc.embed[this.options.id];
    this.container = $('#' + this.options.container);
    this.embed.documents.bind('refresh', _.bind(this.renderDocuments, this));
    this.render();
  },
  
  render : function() {
    $(this.el).html(JST['embed_workspace']({
        options : this.embed.options
    }));
    this.container.html(this.el);
    
    this.search = this.$('.DC-search-box');
    
    this.search.placeholder({className: 'DC-placeholder DC-interface'});
    this.renderDocuments();
    this.showSearchCancel();
    if (!this.originalHeight) {
      var $list = $('.DC-document-list', this.el);
      this.originalHeight = $list.height();
      $list.height(this.originalHeight);
    }
  },
  
  renderDocuments : function() {
    var options        = this.embed.options;
    var $document_list = this.$('.DC-document-list').empty();
    var width          = this.calculateTileWidth();
    
    this.hideSpinner();

    if (!this.embed.documents.length) {
      $document_list.append(JST['no_results']({}));
    } else {
      this.embed.documents.each(_.bind(function(doc) {
        var view = (new dc.EmbedDocumentTile({model: doc})).render(width).el;
        $document_list.append(view);
      }, this));
    }
    this.$('.DC-paginator').removeClass('DC-is-editing').html(JST['paginator']({
      total         : options.total,
      per_page      : options.per_page,
      page          : options.page,
      page_count    : Math.ceil(options.total / options.per_page),
      from          : (options.page-1) * options.per_page,
      to            : Math.min(options.page * options.per_page, options.total),
      title         : options.title,
      dc_url        : options.dc_url,
      workspace_url : options.dc_url + "/#search/" + encodeURIComponent(options.q)
    }));
  },
  
  calculateTileWidth : function() {
    var pageWidth      = $(this.el).width();
    var minWidth       = 300;
    var padding        = 90;
    var remainingWidth = pageWidth % minWidth;
    var tilesPerRow    = Math.floor(pageWidth / minWidth);
    var width          = minWidth + Math.floor(remainingWidth/tilesPerRow);

    return width - padding;
  },
  
  showSearchCancel : function() {
    var show = this.embed.options.q == this.embed.options.originalQuery;

    $(this.el).toggleClass('DC-query-original', show);
    $(this.el).toggleClass('DC-query-search',  !show);
  },
  
  cancelSearch : function(e) {
    e.preventDefault();
    this.search.val('').blur();
    this.performSearch();
  },
  
  maybePerformSearch : function(e) {
    if (e.keyCode != 13) return; // Search on `enter` only
    var force = this.embed.options.page != 1;
    this.embed.options.page = 1;
    this.performSearch(force);
  },
  
  performSearch : function(force) {
    var query = this.$('.DC-search-box').val();
    
    if (query == '' && !force) {
      // Returning to original query, just use the cached original response.
      this.embed.options = _.clone(this.embed.originalOptions);
      this.embed.documents.refresh(this.embed.documents.originalModels);
    } else {
      this.embed.options.q = this.embed.options.originalQuery + (query && (' ' + query));
      this.showSpinner();
      dc.loadSearchEmbed(this.embed.options.searchUrl, this.embed.options);
    }
    
    this.showSearchCancel();
  },
  
  nextPage : function() {
    this.embed.options.page += 1;
    this.performSearch(true);
  },
  
  previousPage : function() {
    this.embed.options.page -= 1;
    this.performSearch(true);
  },

  editPage : function() {
    this.$('.DC-paginator').addClass('DC-is-editing');
    this.$('.DC-page-edit').focus().select();
  },
  
  changePage : function() {
    var page = Math.max(1, Math.min(
      parseInt(this.$('.DC-page-edit').val(), 10), 
      Math.ceil(this.embed.options.total / this.embed.options.per_page)
    ));
    this.embed.options.page = page;
    this.performSearch(true);
  },
  
  showSpinner : function() {
    this.$('.DC-search-glyph').addClass('DC-spinner');
  },
  
  hideSpinner : function() {
    this.$('.DC-search-glyph').removeClass('DC-spinner');
  }
  
});

dc.EmbedDocumentTile = Backbone.View.extend({
  
  events : {
    'click' : 'open'
  },
  
  initialize : function() {},
  
  render : function(width) {
    var titleWidth       = this.fitTitleWidth(width);
    var descriptionWidth = this.fitDescriptionWidth(width);
    
    $(this.el).html(JST['embed_document_tile']({
      doc               : this.model,
      width             : width,
      titleWidth        : titleWidth,
      descriptionWidth  : descriptionWidth
    }));
    return this;
  },
  
  fitTitleWidth : function(width) {
    // Wolfram Alpha: linear fit (490, 115), (285, 65), (210, 45)
    return Math.floor(.248711*width - 10);
  },
  
  fitDescriptionWidth : function(width) {
    // Wolfram Alpha: linear fit (490, 180), (285, 110), (210, 70)
    return Math.floor(.381991*width - 10);
  },
  
  open : function(e) {
    e.preventDefault();

    window.open(this.model.get('resources').published_url || this.model.get('canonical_url'));

    return false;
  }
  
});
