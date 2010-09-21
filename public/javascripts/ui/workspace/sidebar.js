// The Sidebar. Switches contexts between different subviews.
dc.ui.Sidebar = dc.Controller.extend({

  id : 'sidebar',

  render : function() {
    $(this.el).html(JST['workspace/sidebar']({}));
    this.content  = $('#sidebar_content', this.el);
    dc.app.scroller = (new dc.ui.Scroll(this.content)).render();
    return this;
  },

  add : function(containerName, view) {
    $('#' + containerName + '_container', this.el).append(view);
  }

});