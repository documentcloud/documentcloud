(function() {
  var dc = window.dc = window.dc || {};
  dc.embed = dc.embed || {};
  var searches = dc.embed.searches = dc.embed.searches || {};

  var _ = dc._        = window._.noConflict();
  var $ = dc.jQuery   = window.jQuery.noConflict(true);
  dc.Backbone         = Backbone.noConflict();

  dc.embed.load = function(searchUrl, opts) {
    var secure = (/^https/).test(searchUrl);
    var id = dc.inflector.sluggify(opts.original_query || opts.q);

    searches[id] = searches[id] || {};
    searches[id].options = opts = _.extend({}, {
      searchUrl      : searchUrl,
      secure         : secure,
      original_query : opts.original_query || opts.q,
      per_page       : 12,
      order          : 'score',
      search_bar     : true,
      page           : 1,
      title          : null,
      pass_search    : false
    }, opts);

    if (opts.search && !searches[id].isLoaded) {
      searches[id].options.q = opts.q = opts.original_query + ' ' + opts.search;
    }
    var params = encodeURIComponent(opts.q.replace(/\?/g, '')) +
                 '/p-'      + encodeURIComponent(opts.page) +
                 '-per-'    + encodeURIComponent(opts.per_page) +
                 '-order-'  + encodeURIComponent(opts.order) +
                 '-org-'    + encodeURIComponent(opts.organization) +
                 (secure ? '-secure' : '') + '.js';

    // Make sure we haven't been monkey-patched by Omniture.
    // Super, amazingly, ridiculously, hacky. But hey, fight fire with fire.
    window.dc = dc;
    setTimeout(function(){ window.dc = dc; }, 50);
    $.getScript(searchUrl + params);
    dc.embed.pingRemoteUrl('search', encodeURIComponent(opts.original_query || opts.q));
  };

  dc.embed.callback = function(json) {
    var searchQuery = dc.inflector.sluggify(json.query);
    var id = _.detect(_.keys(dc.embed.searches), function(q) {
      return searchQuery.indexOf(q) == 0;
    });
    _.extend(searches[id].options, {
      id       : id,
      total    : json.total,
      per_page : json.per_page,
      page     : json.page,
      dc_url   : json.dc_url
    });
    
    var search = searches[id];
    if (search.isLoaded) {
      search.documents.reset(json.documents);
      if (search.options.search && !search.originalLoaded) {
        search.workspace.render();
      }
      if (search.options.q == search.options.original_query) {
        search.originalLoaded = true;
      }
    } else {
      search.documents       = new dc.EmbedDocumentSet(json.documents, search.options);
      search.workspace       = new dc.EmbedWorkspaceView(search.options);
      search.originalOptions = _.clone(search.options);
      search.isLoaded        = true;
      search.search          = search.workspace.search;
    }
    searches[id] = search;
    
    if (search.options && search.options.afterLoad) search.options.afterLoad(search);
  };

  dc.EmbedDocument = dc.Backbone.Model.extend({

    url : function() {
      return this.get('resources').published_url || this.get('canonical_url');
    },

    isPrivate : function() {
      return this.get('access') == 'organization' || this.get('access') == 'private';
    }

  });

  dc.EmbedDocumentSet = dc.Backbone.Collection.extend({

    model : dc.EmbedDocument,

    initialize : function(models) {
      this.originalModels = models;
    }

  });

  dc.EmbedWorkspaceView = dc.Backbone.View.extend({

    className : 'DC-search-embed DC-unselectable',

    events : {
      'click    .DC-cancel-search' : 'cancelSearch',
      'click    .DC-arrow-right'   : 'nextPage',
      'click    .DC-arrow-left'    : 'previousPage',
      'click    .DC-page-current'  : 'editPage',
      'change   .DC-page-edit'     : 'changePage',
      'keypress .DC-search-box'    : 'maybePerformSearch'
    },

    initialize : function(options) {
      this.options = options;
      _.bindAll(this, 'search');
      this.embed     = searches[this.options.id];
      this.container = $(this.options.container);
      this.embed.documents.bind('reset', _.bind(this.renderDocuments, this));
      this.render();
    },

    render : function() {
      var search = $.trim(this.embed.options.q.replace(this.embed.options.original_query, ''));
      $(this.el).html(JST['search_embed_workspace']({
        options : this.embed.options,
        search  : search
      }));
      this.container.html(this.el);
      this.searchBox = this.$('.DC-search-box');
      this.renderDocuments();
      this.showSearchCancel();
      this.setHeight();
      this.delegateEvents();
    },

    renderDocuments : function() {
      var options = this.embed.options;
      var docList = this.$('.DC-document-list').empty();
      var width   = this.calculateTileWidth();
      var self    = this;

      this.hideSpinner();

      if (!this.embed.documents.length) {
        docList.append(JST['search_no_results']({}));
      } else {
        this.embed.documents.each(function(doc) {
          var view = (new dc.EmbedDocumentTile({model: doc, embed: self.embed})).render(width).el;
          docList.append(view);
        });
      }
      this.$('.DC-paginator').removeClass('DC-is-editing').html(JST['search_paginator']({
        total         : options.total,
        perPage       : options.per_page,
        page          : options.page,
        pageCount     : Math.ceil(options.total / options.per_page),
        from          : (options.page-1) * options.per_page,
        to            : Math.min(options.page * options.per_page, options.total),
        title         : options.title,
        dcUrl         : options.dc_url,
        workspaceUrl  : options.dc_url + (options.secure ? "/#search/" : "/public/search/") +
                        encodeURIComponent(options.q)
      }));
    },

    setHeight : function() {
      var listEl = $('.DC-document-list', this.el);
      listEl.height(listEl.height());
    },

    calculateTileWidth : function() {
      var pageWidth      = $(this.el).width();
      var minWidth       = pageWidth > 300 ? 300 : pageWidth;
      var padding        = 97;
      var remainingWidth = pageWidth % minWidth;
      var tilesPerRow    = Math.floor(pageWidth / minWidth);
      var width          = minWidth + Math.floor(remainingWidth/tilesPerRow);

      if (pageWidth < 380) $(this.el).addClass('DC-skinny-width');

      return width - padding;
    },

    showSearchCancel : function() {
      var show = this.embed.options.q == this.embed.options.original_query;

      $(this.el).toggleClass('DC-query-original', show);
      $(this.el).toggleClass('DC-query-search',  !show);
    },

    cancelSearch : function(e) {
      e.preventDefault();
      this.searchBox.val('').blur();
      this.performSearch();
    },

    maybePerformSearch : function(e) {
      if (e.which != 13) return; // Search on `enter` only
      var force = this.embed.options.page != 1;
      this.embed.options.page = 1;
      this.performSearch(force);
    },

    search : function(query) {
      this.embed.options.page = 1;
      this.performSearch(true, query);
    },

    performSearch : function(force, query) {
      query = query || this.$('.DC-search-box').val() || "";
      this.$('.DC-search-box').val(query);
      this.embed.query = dc.inflector.trim(query);

      // Returning to original query, just use the cached original response.
      if (query == '' && !force && !this.embed.options.search) {
        this.embed.options = _.clone(this.embed.originalOptions);
        this.embed.documents.reset(this.embed.documents.originalModels);
      } else {
        this.embed.options.q = this.embed.options.original_query + (query && (' ' + query));
        this.showSpinner();
        this.$('.DC-document-list').empty();
        dc.embed.load(this.embed.options.searchUrl, this.embed.options);
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

  dc.EmbedDocumentTile = dc.Backbone.View.extend({

    className : 'DC-document-tile-container',

    events : {
      'click.dcSearch a.DC-document-tile' : 'click'
    },

    initialize : function(options) {
      this.options = options;
      this.embed = this.options.embed;
    },

    render : function(width) {
      var hasOrg = !!this.model.get('contributor_organization');
      var hasDesc = !!this.model.get('description');
      $(this.el).html(JST['search_embed_document_tile']({
        dc                : dc,
        doc               : this.model,
        tileWidth         : width,
        titleWidth        : this.fitTitleWidth(width, hasDesc, hasOrg),
        descriptionWidth  : this.fitDescriptionWidth(width, hasOrg),
        showOrg           : hasOrg
      }));
      return this;
    },

    fitTitleWidth : function(width, hasDesc, hasOrg) {
      var multiplier = 0.26;
      if (!hasDesc) multiplier += 0.3;
      if (!hasOrg) multiplier += 0.2;
      return Math.floor(multiplier * width - 10);
    },

    fitDescriptionWidth : function(width, hasOrg) {
      return Math.floor((hasOrg ? 0.35 : 0.55) * width - 10);
    },
    
    click: function(e) {
      if (this.embed.options.click) {
        return this.embed.options.click(e, this);
      } else {
        this.open(e);
      }
    },

    open : function(e) {
      var query   = this.embed.options.pass_search && this.embed.query;
      var suffix  = query ? "#search/p1/" + encodeURIComponent(query) : '';
      var baseUrl = this.model.get('resources').published_url || this.model.get('canonical_url');
      var href    = (this.model.get('resources').published_url || this.model.get('canonical_url')) + suffix;
      var $link   = $(e.target).closest('a.DC-document-tile');
      // Triggering `click.foo` means we skip the `click.dcSearch` observed 
      // event above and just do a native click
      $link.attr('href', href).trigger('click.foo');
    }

  });

  dc.embed.pingRemoteUrl = function(type, id) {
    var loc = window.location;
    var url = loc.protocol + '//' + loc.host + loc.pathname;
    if (url.match(/^file:/)) return false;
    url = url.replace(/[\/]+$/, '');
    var hitUrl = dc.recordHit;
    var key    = encodeURIComponent(type + ':' + id + ':' + url);
    $(document).ready( function(){ $(document.body).append('<img alt="" width="1" height="1" src="' + hitUrl + '?key=' + key + '" />'); });
  };

})();