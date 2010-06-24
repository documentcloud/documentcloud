dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'          : 'showDocuments',
    '.edit_glyph.click' : 'editProject'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
    this.model.view = this;
  },

  render : function() {
    var data = _.extend(this.model.attributes(), {statistics : this.model.statistics()});
    $(this.el).html(JST.organizer_project(data));
    $(this.el).attr({id : "project_" + this.model.cid, 'data-project-cid' : this.model.cid});
    this.setMode(this.model.get('selected') ? 'is' : 'not', 'selected');
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    this.model.open();
  },

  editProject : function(e) {
    $(document.body).append((new dc.ui.ProjectDialog({model : this.model})).render().el);
    return false;
  }

}, {

  // (Maybe) hightlight a project box for the current query.
  highlight : function(query, type) {
    Projects.deselectAll();
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    if (project) return project.set({selected : true});
  }

});
