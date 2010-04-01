dc.util.Bindable = {

  ALL : 'bindable:bind_all',

  // Mix in bindable methods to the target class.
  extend : function(obj) {
    return _.extend(obj, dc.util.Bindable.methods);
  },

  methods : {

    // e -> event object
    // callback -> callback function
    bind : function(e, callback) {
      if (!e)         throw new Error('dc.util.Bindable: Undefined event');
      if (!callback)  throw new Error('dc.util.Bindable: Undefined callback');
      var calls = (this._callbacks = this._callbacks || {});
      var list = (calls[e] = calls[e] || []);
      list.push(callback);
    },

    // Remove one or more callbacks.
    unbind : function(e, callback) {
      var calls = this._callbacks;
      if (!calls) return;
      for (var ev in calls) {
        if (e && e != ev) continue; // Skip events we aren't trying to undo.
        var list = calls[ev], i = (list && list.length) || 0;
        while (i--) if (callback == list[i]) list[i] = null;
      }
    },

    // Remove all bound callbacks.
    unbindAll : function() {
      delete this._callbacks;
    },

    // Fire an event, triggering all bound callbacks.
    fire : function(e) {
      if (!e) throw new Error('dc.util.Bindable: Undefined event');
      var calls = this._callbacks;

      for (var j=0; j<2; j++) {
        var ev = j ? e : dc.util.Bindable.ALL;
        var list = calls && calls[ev], i = (list && list.length) || 0;
        var thin = false;
        while(i--) {
          var callback = list[i];
          if (callback) {
            callback.apply(this, arguments);
          } else {
            thin = true;
          }
        }
        if (thin) {
          calls[ev] = [];
          for (k=0; k<list.length; k++) {
            if (list[k]) calls[ev].push(list[k]);
          }
        }
      }
    }

  }

};