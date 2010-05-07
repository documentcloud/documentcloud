dc.ui.Organizer = dc.View.extend({

  id : 'organizer',

  callbacks : {
    '#new_project.click'      : 'promptNewProject',
    '#upload_document.click'  : 'openUploads'
  },

  facetCallbacks : {
    '.row.click'              : '_filterFacet',
    '.cancel_search.click'    : '_removeFacet',
    '.more.click'             : '_loadFacets',
    '.less.click'             : '_showLess',
    '.show_pages.click'       : '_showPages'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSubView', '_removeSubView', 'openUploads');
    this._bindToSets();
    this.subViews = [];
  },

  render : function() {
    $(this.el).append(JST.organizer_sidebar({}));
    this.projectInputEl = $('#project_input', this.el);
    this.projectList    = $('.project_list', this.el);
    this.entityList     = $('#organizer_entities', this.el);
    this.sidebar        = $('#sidebar');
    this.renderAll();
    this.showTab(dc.app.cookies.read('sidebar_tab') || 'projects');
    this.setCallbacks();
    $('#projects_tab').click(_.bind(this.showTab, this, 'projects'));
    $('#entities_tab').click(_.bind(this.showTab, this, 'entities'));
    return this;
  },

  renderAll : function() {
    if (Projects.empty()) this.setMode('no', 'projects');
    $(this.projectList).append((new dc.ui.Project()).render().el);
    _.each(Projects.models(), _.bind(function(model) {
      this._addSubView(null, model);
    }, this));
  },

  showTab : function(kind) {
    this.sidebar.setMode(kind, 'active');
    $('.sidebar_tab').removeClass('active');
    $('#' + kind + '_tab').addClass('active');
    dc.app.cookies.write('sidebar_tab', kind, true);
    dc.app.scroller.check();
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
    this.entityList.html(JST.organizer_entities({entities : facets, limit : limit}));
    this.setCallbacks(this.facetCallbacks);
    dc.app.scroller.checkLater();
  },

  // Just add to the facets, don't blow them away.
  mergeFacets : function(facets, limit, docCount) {
    this.renderFacets(_.extend(this._facets, facets), limit, docCount);
  },

  promptNewProject : function() {
    var me = this;
    dc.ui.Dialog.prompt('Create a New Project', '', function(title) {
      if (!title) return;
      if (Projects.find(title)) return me._warnAlreadyExists(title);
      var project = new dc.model.Project({title : title, annotation_count : 0, document_ids : []});
      Projects.create(project, null, {error : function() { Projects.remove(project); }});
      return true;
    }, 'short');
  },

  openUploads : function() {
    dc.app.uploader.open();
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
    dc.app.searchBox.addToSearch(this._facetStringFor(e.target));
  },

  _removeFacet : function(e) {
    $(e.target).closest('.row').removeClass('active');
    dc.app.searchBox.removeFromSearch(this._facetMatcherFor(e.target));
    return false;
  },

  _loadFacets : function(e) {
    $(e.target).html('loading &hellip;');
    dc.app.searchBox.loadFacets($(e.target).attr('data-category'));
  },

  _showLess : function(e) {
    var cat = $(e.target).attr('data-category');
    this._facets[cat].splice(6);
    this.renderFacets(this._facets, 5, this._docCount);
  },

  _showPages : function(e) {
    var el = $(e.target).closest('.row');
    var next = function() {
      Entities.fetch(el.attr('data-category'), el.attr('data-value'), function(entities) {
        var sets = _.reduce(entities, {}, function(memo, ent) {
          var docId = ent.get('document_id');
          memo[docId] = memo[docId] || [];
          memo[docId].push(ent);
          return memo;
        });
        _.each(sets, function(set) {
          Documents.get(set[0].get('document_id')).pageEntities.refresh(set);
        });
      });
    };
    if (dc.app.paginator.mini) {
      dc.app.paginator.toggleSize(next);
    } else {
      next();
    }
    return false;
  },

  // Bind all possible and Project events for rendering.
  _bindToSets : function() {
    _.each([Projects], _.bind(function(set) {
      set.bind(dc.Set.MODEL_ADDED, this._addSubView);
      set.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    }, this));
  },

  _warnAlreadyExists : function(title) {
    dc.ui.notifier.show({text : 'A project named "' + title + '" already exists'});
    return false;
  },

  _addSubView : function(e, model) {
    this.setMode('has', 'projects');
    var view = new dc.ui.Project({model : model}).render();
    this.subViews.push(view);
    var models = Projects.models();
    var previous = models[_.indexOf(models, view.model) - 1];
    var previousView = previous && previous.view;
    if (!previous || !previousView) { return $(this.projectList).append(view.el); }
    $(previousView.el).after(view.el);
    dc.app.scroller.checkLater();
  },

  _removeSubView : function(e, model) {
    this.subViews = _.without(this.subViews, model.view);
    $(model.view.el).remove();
    dc.app.scroller.checkLater();
  }

});
