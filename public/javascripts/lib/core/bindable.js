dc.model.Bindable = {

  // Bind an event on this object to a given callback.
  bind : function(e, callback) {
    var calls = this._callbacks || (this._callbacks = {});
    var list  = this._callbacks[e] || (this._callbacks[e] = []);
    list.push(callback);
    return this;
  },

  // Remove one or many callbacks.
  unbind : function(e, callback) {
    var calls;
    if (!e) {
      this._callbacks = {};
    } else if (calls = this.callbacks) {
      if (!callback) {
        calls[e] = [];
      } else {
        var list = calls[e];
        for (var i = 0, l = list.length; i < l; i++) {
          if (callback === list[i]) {
            list.splice(i, 1);
            break;
          }
        }
      }
    }
    return this;
  },

  // Fire an event, triggering all bound callbacks.
  fire : function(e) {
    var calls = this._callbacks;
    for (var i = 0; i < 2; i++) {
      var list = calls && calls[i ? 'all' : e];
      if (!list) continue;
      for (var j = 0, l = list.length; j < l; j++) {
        list[j].apply(this, arguments);
      }
    }
    return this;
  }

};