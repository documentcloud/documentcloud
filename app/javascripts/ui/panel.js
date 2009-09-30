// The main central panel. Switches contexts between different subviews.
dc.ui.Panel = dc.View.extend({
  
  className : 'panel',
  
  // constructor : function(options) {
  //   this.base(options);
  //   $(this.el).addClass('large_size');
  // },
  
  render : function() {
    $(this.el).html(dc.templates.WORKSPACE_PANEL({}));
    this.content = $('.panel_content', this.el);
    return this;
  },
  
  show : function(subview) {
    this.content.html(subview.el);
  }
  
});