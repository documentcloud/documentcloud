// The Sidebar. Switches contexts between different subviews.
dc.ui.Sidebar = dc.View.extend({
  
  className : 'sidebar',
  
  // constructor : function(options) {
  //   this.base(options);
  //   $(this.el).addClass('large_size');
  // },
  
  render : function() {
    $(this.el).html(dc.templates.WORKSPACE_SIDEBAR({}));
    this.content = $('.sidebar_content', this.el);
    return this;
  },
  
  show : function(content) {
    this.content.html(content);
  }
  
});