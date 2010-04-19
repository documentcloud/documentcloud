dc.util.Bindable = {

  // Bind an event on this object to a given callback.
  bind : function(e, callback) {
    var calls = (this._callbacks = this._callbacks || {});
    var list  = (this._callbacks[e] = this._callbacks[e] || []);
    list.push(callback);
  },

  // Remove one or more callbacks.
  unbind : function(e, callback) {
    var calls = this._callbacks;
    if (!calls) return;
    for (var ev in calls) {
      if (e != ev) continue;
      var list = calls[ev];
      for (var i = 0, l = list.length; i < l; i++) {
        if (callback == list[i]) list.splice(i, 1);
      }
    }
  },

  // Remove all bound callbacks.
  unbindAll : function() {
    delete this._callbacks;
  },

  // Fire an event, triggering all bound callbacks.
  fire : function(e) {
    var calls = this._callbacks;
    for (var i = 0; i < 2; i++) {
      var list = calls && calls[i ? e : 'all'];
      if (!list) continue;
      for (var j = 0; j < list.length; j++) {
        list[j].apply(this, arguments);
      }
    }
  }

};