dc.ui.SparkEntities = Backbone.View.extend({

  BLOCK_WIDTH: 275,

  LEFT_WIDTH: 120,

  RIGHT_MARGIN: 50,

  MAX_WIDTH: 700,

  TOOLTIP_DELAY: 250,

  SEARCH_DISTANCE: 5,

  events: {
    'click .cancel_search'           : 'hide',
    'click .show_all'                : 'renderKind',
    'click .entity_line_title'       : '_showPages',
    'click .entity_list_title'       : '_showPages',
    'click .entity_bucket_wrap'      : '_openEntity',
    'click .arrow.left'              : 'render',
    'mouseenter .entity_bucket_wrap' : '_onMouseEnter',
    'mouseleave .entity_bucket_wrap' : '_onMouseLeave'
  },

  initialize : function() {
    this.template = JST['document/entities'];
    this.options.container.append(this.el);
    this.showTooltip = _.debounce(this.showTooltip, this.TOOLTIP_DELAY);
  },

  render : function() {
    this.options.container.show();
    var width = $(this.el).width();
    var rows = Math.floor(width / (this.BLOCK_WIDTH + this.LEFT_WIDTH + this.RIGHT_MARGIN));
    var blockWidth = Math.min(Math.floor((width - ((this.LEFT_WIDTH + this.RIGHT_MARGIN) * rows)) / rows), this.MAX_WIDTH);
    $(this.el).html(this.template({doc : this.model, only: false, width: blockWidth, distance: this.SEARCH_DISTANCE}));
    return this;
  },

  renderKind : function(e) {
    this.options.container.show();
    var kind = $(e.currentTarget).attr('data-kind');
    var fullWidth = Math.min($(this.el).width() - (this.LEFT_WIDTH + this.RIGHT_MARGIN), this.MAX_WIDTH);
    $(this.el).html(this.template({doc : this.model, only: kind, width: fullWidth, distance: this.SEARCH_DISTANCE}));
    this.model.trigger('focus');
  },

  hide : function() {
    $(this.el).html('');
    this.options.container.hide();
  },

  showTooltip : function() {
    if (this._event) {
      this._entity.loadExcerpt(this._occurrence, _.bind(function(excerpt) {
        dc.ui.tooltip.show({
          left  : this._event.pageX,
          top   : this._event.pageY + 5,
          title : this._entity.get('value'),
          text  : '<b>p.' + excerpt.page_number + '</b> ' + dc.inflector.trimExcerpt(excerpt.excerpt)
        });
      }, this));
    }
  },

  _setCurrent : function(e) {
    var found;
    var occ = 'data-occurrence';
    var el = $(e.currentTarget);
    if (el.hasClass('occurs')) {
      var found = el;
    } else {
      var index = el.index();
      var buckets = el.parent().children();
      for (var i = 1, l = this.SEARCH_DISTANCE; i <= l; i++) {
        var after = buckets[index + i], before = buckets[index - i];
        if (el = ($(after).hasClass('occurs') && $(after)) ||
                 ($(before).hasClass('occurs') && $(before))) break;
      }
    }
    if (!el) return false;
    el.addClass('active');
    this._current = el;
    this._occurrence = el.find('.entity_bucket').attr(occ);
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
    if (this._current) this._current.removeClass('active');
    this._event = this._occurrence = this._entity = this._current = null;
  },

  _showPages : function(e) {
    var id = $(e.currentTarget).closest('[data-id]').attr('data-id');
    dc.model.Entity.fetchId(this.model.id, id, _.bind(function(entities) {
      this.hide();
      this.model.pageEntities.reset(entities);
    }, this));
  }

});
