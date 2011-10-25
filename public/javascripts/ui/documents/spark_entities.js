dc.ui.SparkEntities = Backbone.View.extend({

  BLOCK_WIDTH: 275,

  LEFT_WIDTH: 110,

  RIGHT_MARGIN: 50,

  events: {
    'click .cancel_search'      : 'hide',
    'click .show_all'           : 'renderKind',
    'click .entity_line_title'  : '_showPages'
  },

  initialize : function() {
    this.template = JST['document/entities'];
    this.options.container.append(this.el);
  },

  render : function() {
    var width = $(this.el).width();
    var rows = Math.floor(width / (this.BLOCK_WIDTH + this.LEFT_WIDTH + this.RIGHT_MARGIN));
    var blockWidth = Math.floor((width - ((this.LEFT_WIDTH + this.RIGHT_MARGIN) * rows)) / rows);
    $(this.el).html(this.template({doc : this.model, only: false, width: blockWidth}));
    return this;
  },

  renderKind : function(e) {
    var kind = $(e.currentTarget).attr('data-kind');
    var fullWidth = $(this.el).width() - (this.LEFT_WIDTH + this.RIGHT_MARGIN);
    $(this.el).html(this.template({doc : this.model, only: kind, width: fullWidth}));
  },

  hide : function() {
    $(this.el).html('');
  },

  _showPages : function(e) {
    var id = $(e.currentTarget).attr('data-id');
    dc.model.Entity.fetchId(this.model.id, id, _.bind(function(entities) {
      this.hide();
      this.model.pageEntities.reset(entities);
    }, this));
  }

});
