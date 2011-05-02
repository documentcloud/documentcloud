(function() {
  window.dc = window.dc || {};
  dc.embed = dc.embed || {};
  var searches = dc.embed.searches = dc.embed.searches || {};

  var _ = dc._        = window._.noConflict();
  var $ = dc.jQuery   = window.jQuery.noConflict(true);
  dc.Backbone         = Backbone.noConflict();

  dc.embed.load = function(searchUrl, opts) {
    var secure = (/^https/).test(searchUrl);
    var id = dc.inflector.sluggify(opts.originalQuery || opts.q);

    searches[id] = searches[id] || {};
    searches[id].options = opts = _.extend({}, {
      searchUrl     : searchUrl,
      secure        : secure,
      originalQuery : opts.originalQuery || opts.q,
      per_page      : 12,
      order         : 'score',
      search_bar    : true,
      page          : 1,
      title         : null,
      pass_search   : false
    }, opts);

    var params = encodeURIComponent(opts.q.replace(/\?/g, '')) +
                 '/p-'      + encodeURIComponent(opts.page) +
                 '-per-'    + encodeURIComponent(opts.per_page) +
                 '-order-'  + encodeURIComponent(opts.order) +
                 '-org-'    + encodeURIComponent(opts.organization) +
                 (secure ? '-secure' : '') + '.js';

    $.getScript(searchUrl + params);
    dc.embed.pingRemoteUrl('search', encodeURIComponent(opts.originalQuery || opts.q));
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

    if (searches[id].isLoaded) {
      searches[id].documents.refresh(json.documents);
    } else {
      searches[id].documents       = new dc.EmbedDocumentSet(json.documents, searches[id].options);
      searches[id].workspace       = new dc.EmbedWorkspaceView(searches[id].options);
      searches[id].originalOptions = _.clone(searches[id].options);
      searches[id].isLoaded        = true;
    }

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

    initialize : function() {
      this.embed     = searches[this.options.id];
      this.container = $(this.options.container);
      this.embed.documents.bind('refresh', _.bind(this.renderDocuments, this));
      this.render();
    },

    render : function() {
      $(this.el).html(JST['search_embed_workspace']({options : this.embed.options}));
      this.container.html(this.el);

      this.search = this.$('.DC-search-box');

      this.renderDocuments();
      this.showSearchCancel();
      var listEl = $('.DC-document-list', this.el);
      listEl.height(listEl.height());
    },

    renderDocuments : function() {
      var options = this.embed.options;
      var docList = this.$('.DC-document-list').empty();
      var width   = this.calculateTileWidth();

      this.hideSpinner();

      if (!this.embed.documents.length) {
        docList.append(JST['search_no_results']({}));
      } else {
        this.embed.documents.each(_.bind(function(doc) {
          var view = (new dc.EmbedDocumentTile({model: doc, embed: this.embed})).render(width).el;
          docList.append(view);
        }, this));
      }
      this.$('.DC-paginator').removeClass('DC-is-editing').html(JST['search_paginator']({
        total         : options.total,
        per_page      : options.per_page,
        page          : options.page,
        page_count    : Math.ceil(options.total / options.per_page),
        from          : (options.page-1) * options.per_page,
        to            : Math.min(options.page * options.per_page, options.total),
        title         : options.title,
        dc_url        : options.dc_url,
        workspace_url : options.dc_url + (options.secure ? "/#search/" : "/public/#search/") +
                        encodeURIComponent(options.q)
      }));
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
      if (e.which != 13) return; // Search on `enter` only
      var force = this.embed.options.page != 1;
      this.embed.options.page = 1;
      this.performSearch(force);
    },

    performSearch : function(force) {
      var query = this.$('.DC-search-box').val();
      this.embed.query = dc.inflector.trim(query);

      if (query == '' && !force) {
        // Returning to original query, just use the cached original response.
        this.embed.options = _.clone(this.embed.originalOptions);
        this.embed.documents.refresh(this.embed.documents.originalModels);
      } else {
        this.embed.options.q = this.embed.options.originalQuery + (query && (' ' + query));
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

    tagName   : 'a',
    className : 'DC-document-tile',

    events : {
      'click' : 'open'
    },

    initialize : function() {
      this.embed = this.options.embed;
      $(this.el).attr({href: this.model.url()});
      if (this.model.isPrivate()) $(this.el).addClass('DC-document-private');
    },

    render : function(width) {
      var el               = $(this.el);
      var showOrg          = !!this.model.get('contributor_organization');
      var titleWidth       = this.fitTitleWidth(width);
      var descriptionWidth = this.fitDescriptionWidth(width, showOrg);

      el.css({width: width});
      el.toggleClass('DC-show-organization', showOrg);
      el.html(JST['search_embed_document_tile']({
        doc               : this.model,
        titleWidth        : titleWidth,
        descriptionWidth  : descriptionWidth
      }));
      return this;
    },

    fitTitleWidth : function(width) {
      return Math.floor(0.26 * width - 10);
    },

    fitDescriptionWidth : function(width, showOrg) {
      return Math.floor((showOrg ? 0.35 : 0.55) * width - 10);
    },

    open : function(e) {
      var query   = this.embed.options.pass_search && this.embed.query;
      var suffix  = query ? "#search/p1/" + encodeURIComponent(query) : '';
      var baseUrl = this.model.get('resources').published_url || this.model.get('canonical_url');
      window.open((this.model.get('resources').published_url || this.model.get('canonical_url')) + suffix);
      return false;
    }

  });
  
  dc.embed.pingRemoteUrl = function(type, id) {
    var loc = window.location;
    var url = loc.protocol + '//' + loc.host + loc.pathname + loc.search;
    if (url.match(/^file:/)) return false;
    url = url.replace(/[\/]+$/, '');
    var hitUrl = dc.recordHit;
    var key    = encodeURIComponent(id + ':' + url);
    $(document.body).append('<img alt="" width="1" height="1" src="' + hitUrl + '?type=' + type + '&key=' + key + '" />');
  };

})();