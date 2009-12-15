// The Sidebar. Switches contexts between different subviews.
dc.ui.Sidebar = dc.View.extend({
  
  className : 'sidebar',
  
  // constructor : function(options) {
  //   this.base(options);
  //   $(this.el).addClass('large_size');
  // },
  
  render : function() {
    $(this.el).html(JST.workspace_sidebar({}));
    this.content = $('.sidebar_content', this.el);
    return this;
  },
  
  add : function(containerName, view) {
    $('#' + containerName + '_container', this.el).append(view);
  }
  
});