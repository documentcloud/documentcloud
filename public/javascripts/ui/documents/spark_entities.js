dc.ui.SparkEntities = Backbone.View.extend({

  BLOCK_WIDTH: 275,

  LEFT_WIDTH: 110,

  RIGHT_MARGIN: 50,

  MAX_WIDTH: 700,

  TOOLTIP_DELAY: 250,

  events: {
    'click .cancel_search'           : 'hide',
    'click .show_all'                : 'renderKind',
    'click .entity_line_title'       : '_showPages',
    'click .entity_bucket_wrap'      : '_openEntity',
    'mouseenter .entity_bucket_wrap' : '_onMouseEnter',
    'mouseleave .entity_bucket_wrap' : '_onMouseLeave'
  },

  initialize : function() {
    this.template = JST['document/entities'];
    this.options.container.append(this.el);
    this.showTooltip = _.debounce(this.showTooltip, this.TOOLTIP_DELAY);
  },

  render : function() {
    var width = $(this.el).width();
    var rows = Math.floor(width / (this.BLOCK_WIDTH + this.LEFT_WIDTH + this.RIGHT_MARGIN));
    var blockWidth = Math.min(Math.floor((width - ((this.LEFT_WIDTH + this.RIGHT_MARGIN) * rows)) / rows), this.MAX_WIDTH);
    $(this.el).html(this.template({doc : this.model, only: false, width: blockWidth}));
    return this;
  },

  renderKind : function(e) {
    var kind = $(e.currentTarget).attr('data-kind');
    var fullWidth = Math.min($(this.el).width() - (this.LEFT_WIDTH + this.RIGHT_MARGIN), this.MAX_WIDTH);
    $(this.el).html(this.template({doc : this.model, only: kind, width: fullWidth}));
  },

  hide : function() {
    $(this.el).html('');
  },

  showTooltip : function() {
    if (this._event) {
      this._entity.loadExcerpt(this._occurrence, _.bind(function(excerpt) {
        var title   = dc.inflector.truncate(this._entity.get('value'));
        dc.ui.tooltip.show({
          left  : this._event.pageX,
          top   : this._event.pageY + 5,
          title : title,
          text  : '<b>p.' + excerpt.page_number + '</b> ' + dc.inflector.trimExcerpt(excerpt.excerpt)
        });
      }, this));
    }
  },

  _setCurrent : function(e) {
    var el = $(e.currentTarget);
    this._occurrence = el.find('.entity_bucket').attr('data-occurrence');
    if (!this._occurrence) return false;
    var id = el.closest('.entity_line').attr('data-id');
    this._entity = this.model.entities.get(id);
    this._event = e;
    return true;
  },

  _openEntity : function(e) {
    if (!this._setCurrent(e)) return;
    this.model.openEntity(this._entity.id, this._occurrence.split(':')[0]);
  },

  _onMouseEnter : function(e) {
    if (!this._setCurrent(e)) return;
    this.showTooltip();
  },

  _onMouseLeave : function() {
    this._event = this._occurrence = this._entity = null;
  },

  _showPages : function(e) {
    var id = $(e.currentTarget).closest('.entity_line').attr('data-id');
    dc.model.Entity.fetchId(this.model.id, id, _.bind(function(entities) {
      this.hide();
      this.model.pageEntities.reset(entities);
    }, this));
  }

});
