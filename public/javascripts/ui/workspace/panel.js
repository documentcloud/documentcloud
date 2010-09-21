// The main central panel. Switches contexts between different subviews.
dc.ui.Panel = dc.Controller.extend({

  className : 'panel_container',

  render : function() {
    $(this.el).html(JST['workspace/panel']({}));
    this.content = $('.panel_content', this.el);
    this._setMinHeight();
    $(window).resize(_.bind(this._setMinHeight, this));
    return this;
  },

  add : function(containerName, view) {
    $('#' + containerName + '_container', this.el).append(view);
  },

  _setMinHeight : function() {
    $(this.el).css({"min-height": $(window).height() - 120});
  }

});