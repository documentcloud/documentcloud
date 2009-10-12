// Extend the JQuery namespace with core utility methods for DOM manipulation.
$.extend({

  // Quick-create a dom element with attributes.
  el : function(tagName, attributes) {
    var el = document.createElement(tagName);
    $(el).attr(attributes);
    return el;
  },
  
  // See dc.View#setMode...
  setMode : function(el, state, group) {
    group = group || 'mode';
    var re = new RegExp("\\w+_" + group + "(\\s|$)", 'g');
    var mode = (state === null) ? "" : state + "_" + group;
    var name = el.className.replace(re, '') + ' ' + mode;
    name = name.replace(/\s\s/g, ' ');
    el.className = name;
    return mode;
  },
  
  // Align an element relative to a target element's coordinates. Forces the
  // element to be absolutely positioned. Element must be visible.
  // Position string format is: "top -right".
  // You can pass an optional offset object with top and left offsets specified.
  align : function(el, target, pos, offset) {
    el = $(el);
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
      width : target.width(),
      height : target.height()
    };
    
    var elb = {
      width : el.width(),
      height : el.height()
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

  // Javascript templating a-la ERB, pilfered from John Resig's 
  // "Secrets of the Javascript Ninja", page 83.
  template : function(str, data) {
    var fn = new Function('obj', 
      'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'with(obj){p.push(\'' +
      str
        .replace(/[\r\t\n]/g, " ") 
        .split("<%").join("\t") 
        .replace(/((^|%>)[^\t]*)'/g, "$1\r") 
        .replace(/\t=(.*?)%>/g, "',$1,'") 
        .split("\t").join("');") 
        .split("%>").join("p.push('") 
        .split("\r").join("\\'") 
    + "');}return p.join('');");
    return data ? fn(data) : fn;  
  }

});