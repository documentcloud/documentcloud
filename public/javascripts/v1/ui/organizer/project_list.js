dc.ui.ProjectList = dc.View.extend({

  id : 'project_list',

  callbacks : {},

  render : function() {
    var el = $(this.el);
    el.empty();
    _.each(Projects.models(), function(m){
      el.append(new dc.ui.Project({model : m}).render().el);
    });
    return this;
  }

});
