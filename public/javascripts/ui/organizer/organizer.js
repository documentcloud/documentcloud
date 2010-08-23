dc.ui.Organizer = dc.View.extend({

  id : 'organizer',

  TOP_LEVEL_SEARCHES: [
    'all_documents', 'your_documents', 'published_documents', 'org_documents'
  ],

  callbacks : {
    '#new_project.click'          : 'promptNewProject',
    '.all_documents.click'        : 'showAllDocuments',
    '.your_documents.click'       : 'showYourDocuments',
    '.org_documents.click'        : 'showOrganizationDocuments',
    '.published_documents.click'  : 'showPublishedDocuments',
    '.row.click'                  : '_filterFacet',
    '.cancel_search.click'        : '_removeFacet',
    '.more.click'                 : '_loadFacet',
    '.less.click'                 : '_showLess',
    '.show_pages.click'           : '_showPages'
  },

  constructor : function(options) {
    this.base(options);
    this._populatedDocs = false;
    _.bindAll(this, '_addSubView', '_removeSubView', '_ensurePublishedDocs');
    this._bindToSets();
    dc.app.navigation.bind('tab:publish', this._ensurePublishedDocs);
    this.subViews = [];
  },

  render : function() {
    $(this.el).append(JST['organizer/sidebar']({searches : this.TOP_LEVEL_SEARCHES}));
    this.projectInputEl = $('#project_input', this.el);
    this.projectList    = $('.project_list', this.el);
    this.docList        = $('.publish_doc_list', this.el);
    this.entityList     = $('#organizer_entities', this.el);
    this.sidebar        = $('#sidebar');
    this.renderAll();
    this.setCallbacks();
    return this;
  },

  renderAll : function() {
    if (Projects.empty()) this.setMode('no', 'projects');
    _.each(Projects.models(), _.bind(function(model) {
      this._addSubView(null, model);
    }, this));
  },

  // Refresh the facets with a new batch.
  renderFacets : function(facets, limit, docCount) {
    this._docCount = docCount;
    var filtered   = dc.app.SearchParser.extractEntities(dc.app.searchBox.value());
    _.each(filtered, function(filter) {
      var list  = facets[filter.type];
      if (!list) return;
      var index = null;
      var facet = _.detect(list, function(f, i) {
        index = i;
        return f.value.toLowerCase() == filter.value.toLowerCase();
      });
      if (facet) {
        facet.active = true;
        list.splice(index, 1);
      } else {
        facet = {value : filter.value, count : docCount, active : true};
        list.pop();
      }
      facets[filter.type].unshift(facet);
    });
    this._facets = facets;
    this.entityList.html(JST['organizer/entities']({entities : facets, limit : limit}));
    dc.app.scroller.checkLater();
  },

  // Just add to the facets, don't blow them away.
  mergeFacets : function(facets, limit, docCount) {
    this.renderFacets(_.extend(this._facets, facets), limit, docCount);
  },

  promptNewProject : function() {
    var me = this;
    dc.ui.Dialog.prompt('Create a New Project', '', function(title, dialog) {
      title = Inflector.trim(title);
      if (!title) {
        dialog.error('Please enter a title.');
        return;
      }
      if (Projects.find(title)) return me._warnAlreadyExists(title);
      var count = _.inject(Documents.selected(), function(memo, doc){ return memo + doc.get('annotation_count'); }, 0);
      var project = new dc.model.Project({title : title, annotation_count : count, document_ids : Documents.selectedIds(), owner : true});
      Projects.create(project, null, {error : function() { Projects.remove(project); }});
      return true;
    }, {mode : 'short_prompt'});
  },

  showAllDocuments : function() {
    dc.app.searcher.search('');
  },

  showYourDocuments : function() {
    Accounts.current().openDocuments();
  },

  showPublishedDocuments : function() {
    Accounts.current().openDocuments({published : true});
  },

  showOrganizationDocuments : function() {
    Accounts.current().openOrganizationDocuments();
  },

  _facetStringFor : function(el) {
    var row = $(el).closest('.row');
    var val = row.attr('data-value');
    if (val.match(/\s/)) val = '"' + val + '"';
    return row.attr('data-category') + ': ' + val;
  },

  _facetMatcherFor : function(el) {
    var row = $(el).closest('.row');
    var val = row.attr('data-value');
    var cat = row.attr('data-category');
    return new RegExp('\\s*' + cat + ':\\s*[\'"]?' + val + '[\'"]?', 'ig');
  },

  _filterFacet : function(e) {
    dc.app.searcher.addToSearch(this._facetStringFor(e.target));
  },

  _removeFacet : function(e) {
    $(e.target).closest('.row').removeClass('active');
    dc.app.searcher.removeFromSearch(this._facetMatcherFor(e.target));
    return false;
  },

  _loadFacet : function(e) {
    $(e.target).html('loading &hellip;');
    dc.app.searcher.loadFacet($(e.target).attr('data-category'));
  },

  _showLess : function(e) {
    var cat = $(e.target).attr('data-category');
    this._facets[cat].splice(6);
    this.renderFacets(this._facets, 5, this._docCount);
  },

  _showPages : function(e) {
    var el        = $(e.target).closest('.row');
    var kind      = el.attr('data-category');
    var value     = el.attr('data-value');
    var active    = el.hasClass('active');
    var fetch     = _.bind(function() {
      dc.model.Entity.fetch(kind, value, this._connectExcerpts);
    }, this);
    var next = fetch;
    if (!active) {
      next = _.bind(function() {
        dc.app.searcher.addToSearch(this._facetStringFor(el), fetch);
      }, this);
    }
    if (dc.app.paginator.mini) {
      dc.app.paginator.toggleSize(next);
    } else {
      next();
    }
    return false;
  },

  _connectExcerpts : function(entities) {
    var sets = _.reduce(entities, function(memo, ent) {
      var docId = ent.get('document_id');
      memo[docId] = memo[docId] || [];
      memo[docId].push(ent);
      return memo;
    }, {});
    _.each(sets, function(set) {
      Documents.get(set[0].get('document_id')).pageEntities.refresh(set);
    });
  },

  // Bind all possible and Project events for rendering.
  _bindToSets : function() {
    Projects.bind('set:added',    this._addSubView);
    Projects.bind('set:removed',  this._removeSubView);
  },

  _ensurePublishedDocs : function() {
    if (this._populatedDocs) return;
    // $.ajax({
    //       url:      '/documents/unpublished.json',
    //       data:     {},
    //       success:  function(){ alert('yo'); },
    //       error:    Accounts.forceLogout,
    //       dataType: 'json'
    //     });
    this._populatedDocs = true;
  },

  _warnAlreadyExists : function(title) {
    dc.ui.notifier.show({text : 'A project named "' + title + '" already exists'});
    return false;
  },

  _addSubView : function(e, model) {
    this.setMode('has', 'projects');
    var view = new dc.ui.Project({model : model}).render();
    this.subViews.push(view);
    var models        = Projects.models();
    var index         = _.indexOf(models, view.model);
    var previous      = models[index - 1];
    var previousView  = previous && previous.view;
    if (index == 0 || !previous || !previousView) {
      $(this.projectList).prepend(view.el);
    } else {
      $(previousView.el).after(view.el);
    }
    dc.app.scroller.checkLater();
  },

  _removeSubView : function(e, model) {
    this.subViews = _.without(this.subViews, model.view);
    $(model.view.el).remove();
    dc.app.scroller.checkLater();
  }

});
