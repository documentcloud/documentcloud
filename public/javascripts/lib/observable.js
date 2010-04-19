dc.util.Observable = {

  // Bind an event on this object to a given callback.
  bind : function(e, callback) {
    var obs  = (this._observers = this._observers || {});
    var list = (this._observers[e] = this._observers[e] || []);
    list.push(callback);
  },

  // Remove one or more callbacks.
  unbind : function(e, callback) {
    var calls = this._observers;
    if (!calls) return;
    for (var ev in calls) {
      if (e && e != ev) continue; // Skip events we aren't trying to undo.
      var list = calls[ev], i = (list && list.length) || 0;
      while (i--) if (callback == list[i]) list[i] = null;
    }
  },

  // Remove all bound callbacks.
  unbindAll : function() {
    delete this._observers;
  },

  // Fire an event, triggering all bound callbacks.
  fire : function(e) {
    var calls = this._observers;

    for (var j=0; j<2; j++) {
      var ev = j ? e : 'all';
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

};