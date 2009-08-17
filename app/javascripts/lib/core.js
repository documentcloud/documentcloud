// JQuery doesn't provide much support for functional programming: re-implement
// a bunch of functional methods from Prototype and Steele's Functional.
window.$break = '__break__';

window._ = {
    
  // The centerpiece, an each implementation.
  // Handles objects implementing _each, arrays, and raw objects.
  each : function(obj, iterator, context) {
    var index = 0;
    try {
      if (obj.length) {
        for (var i=0; i<obj.length; i++) {
          iterator.call(context, obj[i], i);
        }
      } else if (obj._each) {
        obj._each(function(value) {
          iterator.call(context, value, index++);
        });
      } else {
        var i = 0;
        for (var key in obj) {
          var value = obj[key], pair = [key, value];
          pair.key = key;
          pair.value = value;
          iterator.call(context, pair, i++);
        }
      }
    } catch(e) {
      if (e != $break) throw e;
    }
    return obj;
  },
  
  // Determine whether all of the elements match a truth test.
  all : function(obj, iterator, context) {
    var result = true;
    _.each(obj, function(value, index) {
      result = result && !!iterator.call(context, value, index);
      if (!result) throw $break;
    });
    return result;
  },
  
  // Determine if at least one element in the object matches a truth test.
  any : function(obj, iterator, context) {
    var result = false;
    _.each(obj, function(value, index) {
      if (result = !!iterator.call(context, value, index)) throw $break;
    });
    return result;
  },
  
  // Return the results of applying the iterator to each element.
  map : function(obj, iterator, context) {
    var results = [];
    _.each(obj, function(value, index) {
      results.push(iterator.call(context, value, index));
    });
    return results;
  },
  
  // Return the first value which passes a truth test.
  detect : function(obj, iterator, context) {
    var result;
    _.each(obj, function(value, index) {
      if (iterator.call(context, value, index)) {
        result = value;
        throw $break;
      }
    });
    return result;
  },
  
  // Return all the elements that pass a truth test.
  select : function(obj, iterator, context) {
    var results = [];
    _.each(obj, function(value, index) {
      if (iterator.call(context, value, index)) results.push(value);
    });
    return results;
  },
  
  // Determine if a given value is included in the object, based on '=='.
  include : function(obj, target) {
    if (_.isArray(obj)) if (_.indexOf(obj, target) != -1) return true;
    var found = false;
    _.each(obj, function(value) {
      if (value == target) {
        found = true;
        throw $break;
      }
    });
    return found;
  },
  
  // Aka reduce. Inject builds up a single result from a list of values.
  inject : function(obj, memo, iterator, context) {
    _.each(obj, function(value, index) {
      memo = iterator.call(context, memo, value, index);
    });
    return memo;
  },
  
  // Invoke a method with arguments on every item in a collection.
  invoke : function(obj, method) {
    var args = _.toArray(arguments).slice(2);
    return _.map(obj, function(value) {
      return value[method].apply(value, args);
    });
  },
  
  // Return the maximum item or (item-based computation).
  max : function(obj, iterator, context) {
    var result;
    _.each(obj, function(value, index) {
      value = iterator ? iterator.call(context, value, index) : value;
      if (result == null || value >= result) result = value;
    });
    return result;
  },
  
  // Return the minimum element (or element-based computation).
  min : function(obj, iterator, context) {
    var result;
    _.each(obj, function(value, index) {
      value = iterator ? iterator.call(context, value, index) : value;
      if (result == null || value < result) result = value;
    });
    return result;
  },
  
  // Optimized version of a common use case of map: fetching a property.
  pluck : function(obj, key) {
    var results = [];
    _.each(obj, function(value){ results.push(value[key]); });
    return results;
  },
  
  // Return all the elements for which a truth test fails.
  reject : function(obj, iterator, context) {
    var results = [];
    _.each(obj, function(value, index) {
      if (!iterator.call(context, value, index)) results.push(value);
    });
    return results;
  },
  
  // Sort the object's values by a criteria produced by an iterator.
  sortBy : function(obj, iterator, context) {
    return _.pluck(_.map(obj, function(value, index) {
      return {
        value : value,
        criteria : iterator.call(context, value, index)
      };
    }).sort(function(left, right) {
      var a = left.criteria, b = right.criteria;
      return a < b ? -1 : a > b ? 1 : 0;
    }), 'value');
  },
  
  // Use a comparator function to figure out at what index an object should
  // be inserted so as to maintain order. Uses binary search.
  sortedIndex : function(array, comparator, obj) {
    var low = 0, high = array.length;
    while (low < high) {
      var mid = (low + high) >> 1;
      comparator(array[mid], obj) < 0 ? low = mid + 1 : high = mid;
    }
    return low;
  },
  
  // Convert anything iterable into a real, live array.
  toArray : function(iterable) {
    if (!iterable) return [];
    if (_.isArray(iterable)) return iterable;
    return _.map(iterable, function(val){ return val; });
  },
  
  // Return the number of elements in an object.
  size : function(obj) {
    _.toArray(obj).length;
  },
  
  //------------- The following methods only apply to arrays. -----------------
  
  // Get the first element of an array.
  first : function(array) {
    return array[0];
  },
  
  // Get the last element of an array.
  last : function(array) {
    return array[array.length - 1];
  },
  
  // Trim out all falsy values from an array.
  compact : function(array) {
    return _.select(array, function(value){ return !!value; });
  },
  
  // Return a completely flattened version of an array.
  flatten : function(array) {
    return _.inject(array, [], function(memo, value) {
      if (_.isArray(value)) return memo.concat(_.flatten(value));
      memo.push(value);
      return memo;
    });
  },
  
  // Return a version of the array that does not contain the specified value.
  without : function(array) {
    var values = array.slice.call(arguments, 0);
    return _.select(function(value){ return !_.include(values, value); });
  },
  
  // reverse seems to be implemented natively ... if it turns out not to
  // be in all browsers ... put it here.
  
  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  uniq : function(array, sorted) {
    return _.inject(array, [], function(memo, el, i) {
      if (0 == i || (sorted ? _.last(memo) != el : !_.include(memo, el))) memo.push(el);
      return memo;
    });
  },
  
  // Produce an array that contains every item shared between two given arrays.
  intersect : function(array1, array2) {
    return _.select(_.uniq(array1), function(item1) {
      return _.detect(array2, function(item2) { return item1 === item2; });
    });
  },
  
  // If the browser doesn't supply us with indexOf, we might need this function.
  // Return the position of the first occurence of an item in an array,
  // or -1 if the item is not included in the array.
  // indexOf : function(array, item) {
  //   var length = array.length;
  //   for (i=0; i<length; i++) if (array[i] === item) return i;
  //   return -1;
  // }
  
  /* ---------------- The following methods apply to objects ---------------- */
  
  keys : function(obj) {
    return _.pluck(obj, 'key');
  },
  
  values : function(obj) {
    return _.pluck(obj, 'value');
  },
  
  extend : function(destination, source) {
    for (var property in source) destination[property] = source[property];
    return destination;
  },
  
  clone : function(obj) {
    return _.extend({}, obj);
  },
  
  isElement : function(obj) {
    return !!(obj && obj.nodeType == 1);
  },
  
  isArray : function(obj) {
    return Object.prototype.toString.call(obj) == '[object Array]';
  },
  
  isFunction : function(obj) {
    return typeof obj == 'function';
  },
  
  isUndefined : function(obj) {
    return typeof obj == 'undefined';
  },
  
  toString : function(obj) {
    return obj == null ? '' : String(obj);
  },

  // Don't think we need this ... jQuery should hande it for us.
  //
  // toQueryString : function(obj) {
  //   var encURI = window.encodeURIComponent;
  //   return _.inject(obj, [], function(results, pair) {
  //     var key = encodeURIComponent(pair.key), values = pair.value;
  //     if (values && typeof values == 'object') {
  //       if (_.isArray(values)) { 
  //         return results.concat(_.map(values, function(val) {
  //           return _.isUndefined(val) ? key : key + '=' + encURI(_.toString(val));
  //         }));
  //       }
  //     } else {
  //       results.push(_.isUndefined(values) ? key : key + '=' + encURI(_.toString(values)));
  //     }
  //     return results;
  //   }).join('&');
  // }
  
  bind : function(func, context) {
    if (!context) return func;
    var args = _.toArray(arguments).slice(2);
    return function() {
      var a = args.concat(_.toArray(arguments));
      return func.apply(context, a);
    };
  },
  
  uniqueId : function(prefix) {
    var id = this._idCounter = (this._idCounter || 0) + 1;
    return prefix ? prefix + id : id;
  },
  
  // Perform a deep comparison to check if two objects are equal.
  isEqual : function(a, b) {
    // Check object identity.
    if (a === b) return true;
    // Different types?
    var at = typeof(a), bt = typeof(b);
    if (at != bt) return false;
    // Basic equality test (watch out for coercions).
    if (a == b) return true;
    // One of them implements an isEqual()?
    if (a.isEqual) return a.isEqual(b);
    // Nothing else worked, deep compare the contents.
    return at === 'object' && _.isEqualContents(a, b);
  },
  
  // Objects have equal contents if they have the same keys, and all the values
  // are equal (as defined by _.isEqual).
  _isEqualContents : function(a, b) {
    var aKeys = _.keys(a), bKeys = _.keys(b);
    if (aKeys.length != bKeys.length) return false;
    for (var key in a) if (!_.isEqual(a[key], b[key])) return false;
    return true; 
  }
  
};

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
