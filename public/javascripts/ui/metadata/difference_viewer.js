dc.ui.DifferenceViewer = Backbone.View.extend({

  className: 'difference_viewer',

  initialize: function() {
    this.render();
  },

  render: function() {
    this.$el.html(JST['document/differences']());
    $('#content .panel_content').append(this.el);
    $('body').addClass('showing_differences');
  },

  close: function() {
    $('body').removeClass('showing_differences');
    this.$el.remove();
  }

});