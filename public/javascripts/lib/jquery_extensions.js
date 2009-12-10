// Extend the JQuery namespace with core utility methods for DOM manipulation.
$.extend({

  // Quick-create a dom element with attributes.
  el : function(tagName, attributes, content) {
    var el = document.createElement(tagName);
    if (attributes) $(el).attr(attributes);
    if (content) $(el).html(content);
    return el;
  }

});

$.fn.extend({

  // Align an element relative to a target element's coordinates. Forces the
  // element to be absolutely positioned. Element must be visible.
  // Position string format is: "top -right".
  // You can pass an optional offset object with top and left offsets specified.
  align : function(target, pos, offset) {
    var el = this;
    target = $(target);
    pos = pos || '';
    offset = offset || {};
    var scrollTop = document.documentElement.scrollTop || document.body.scrollTop || 0;
    var scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft || 0;
    var clientWidth = document.documentElement.clientWidth;
    var clientHeight = document.documentElement.clientHeight;

    // var targPos = target.position();
    var targOff = target.offset();
    var b = {
      left : targOff.left - scrollLeft,
      top : targOff.top - scrollTop,
      width : target.innerWidth(),
      height : target.innerHeight()
    };

    var elb = {
      width : el.innerWidth(),
      height : el.innerHeight()
    };

    var left, top;

    if (pos.indexOf('-left') >= 0) {
      left = b.left;
    } else if (pos.indexOf('left') >= 0) {
      left = b.left - elb.width;
    } else if (pos.indexOf('-right') >= 0) {
      left = b.left + b.width - elb.width;
    } else if (pos.indexOf('right') >= 0) {
      left = b.left + b.width;
    } else { // Centered.
      left = b.left + (b.width - elb.width) / 2;
    }

    if (pos.indexOf('-top') >= 0) {
      top = b.top;
    } else if (pos.indexOf('top') >= 0) {
      top = b.top - elb.height;
    } else if (pos.indexOf('-bottom') >= 0) {
      top = b.top + b.height - elb.height;
    } else if (pos.indexOf('bottom') >= 0) {
      top = b.top + b.height;
    } else { // Centered.
      top = b.top + (b.height - elb.height) / 2;
    }

    var constrain = (pos.indexOf('no-constraint') >= 0) ? false : true;

    left += offset.left || 0;
    top += offset.top || 0;

    if (constrain) {
      left = Math.max(scrollLeft, Math.min(left, scrollLeft + clientWidth - elb.width));
      top = Math.max(scrollTop, Math.min(top, scrollTop + clientHeight - elb.height));
    }

    var offParent;
    if (offParent = el.offsetParent()) {
      left -= offParent.offset().left;
      top -= offParent.offset().top;
    }

    $(el).css({position : 'absolute', left : left + 'px', top : top + 'px'});
    return el;
  },

  // See dc.View#setMode...
  setMode : function(state, group) {
    group = group || 'mode';
    var re = new RegExp("\\w+_" + group + "(\\s|$)", 'g');
    var mode = (state === null) ? "" : state + "_" + group;
    var name = this[0].className.replace(re, '') + ' ' + mode;
    name = name.replace(/\s\s/g, ' ');
    this[0].className = name;
    return mode;
  },

  // A-la serializeArray but returns a hash instead of a list.
  serializeJSON : function() {
    return _.inject(this.serializeArray(), {}, function(hash, pair) {
      hash[pair.name] = pair.value;
      return hash;
    });
  },

  // When the next click or keypress happens, anywhere on the screen, hide the
  // element. 'clickable' makes the element and its contents clickable without
  // hiding. The 'onHide' callback runs when the hide fires, and has a chance
  // to cancel it.
  autohide : function(options) {
    var me = this;
    options = _.extend({clickable : null, onHide : null}, options || {});
    me._autoignore = true;
    setTimeout(function(){ delete me._autoignore; }, 0);

    if (!me._autohider) {
      this._autohider = function(e) {
        if (me._autoignore) return;
        if (options.clickable && (me[0] == e.target || _.include($(e.target).parents(), me[0]))) return;
        if (options.onHide && !options.onHide(e)) return;
        me.hide();
        $(document).unbind('click', me._autohider);
        $(document).unbind('keypress', me._autohider);
        me._autohider = null;
      };
      $(document).bind('click', this._autohider);
      $(document).bind('keypress', this._autohider);
    }
  },

  draggable : function() {
    this.each(function() {
      var drag = _.bind(function(e) {
        e.stopPropagation() && e.preventDefault();
        this.style.left = this._drag.left + event.pageX - this._drag.x + 'px';
        this.style.top  = this._drag.top + event.pageY - this._drag.y + 'px';
      }, this);
      var dragEnd = _.bind(function(e) {
        e.stopPropagation() && e.preventDefault();
        $(document.body).unbind('mouseup', dragEnd);
        $(document.body).unbind('mousemove', drag);
        $(this).removeClass('dragging');
      }, this);
      var dragStart = _.bind(function(e) {
        e.stopPropagation() && e.preventDefault();
        $(this).addClass('dragging');
        this._drag = {
          left : parseInt(this.style.left, 10) || 0,
          top  : parseInt(this.style.top, 10) || 0,
          x    : e.pageX,
          y    : e.pageY
        };
        $(document.body).bind('mouseup', dragEnd);
        $(document.body).bind('mousemove', drag);
      }, this);
      $(this).bind('mousedown', dragStart);
    });
  }

});