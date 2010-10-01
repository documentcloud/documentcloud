// The main central panel. Switches contexts between different subviews.
dc.ui.Panel = Backbone.View.extend({

  className : 'panel_container',

  render : function() {
    $(this.el).html(JST['workspace/panel']({}));
    this.content = this.$('.panel_content');
    this._setMinHeight();
    $(window).resize(_.bind(this._setMinHeight, this));
    return this;
  },

  add : function(containerName, view) {
    this.$('#' + containerName + '_container').append(view);
  },

  _setMinHeight : function() {
    $(this.el).css({"min-height": $(window).height() - 120});
  }

});