// The Sidebar. Switches contexts between different subviews.
dc.ui.Sidebar = dc.View.extend({

  id : 'sidebar',

  render : function() {
    $(this.el).html(JST.workspace_sidebar({}));
    this.content = $('.sidebar_content', this.el);
    return this;
  },

  add : function(containerName, view) {
    $('#' + containerName + '_container', this.el).append(view);
  }

});