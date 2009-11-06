// The main central panel. Switches contexts between different subviews.
dc.ui.Panel = dc.View.extend({
  
  className : 'panel_container',
  
  render : function() {
    $(this.el).html(JST.workspace_panel({}));
    this.content = $('.panel_content', this.el);
    return this;
  },
  
  add : function(containerName, view) {
    $('#' + containerName + '_container', this.el).append(view);
  }
  
});