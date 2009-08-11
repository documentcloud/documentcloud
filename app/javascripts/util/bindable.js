dc.util.Bindable = {
  
  UNBIND : 'bindable:unbind',
  ALL_EVENTS : 'bindable:bind_all',
  
  // Mix in bindable methods to the target class.
  extend : function(obj) {
    return $.extend(obj, dc.util.Bindable.methods);
  },
  
  methods : {
    
    // e -> event object
    // callback -> callback function
    // scope -> optional scoping object
    // message -> optional message to be invoked every time the callback fires
    bind : function(e, callback, scope, message) {
      if (!e)         throw('dc.util.Bindable: Undefined event');
      if (!callback)  throw('dc.util.Bindable: Undefined callback');
      var calls = (this.__callbacks__ = this.__callbacks__ || {});
      var list = (calls[e] = calls[e] || []);
      list.push({
        callback : callback,
        scope : scope,
        message : message
      });
    },
    
    // Remove one or more callbacks.
    unbind : function(e, callback, scope) {
      var calls = this.__callbacks__;
      if (!calls) return;
      for (var ev in calls) {
        if (e && e != ev) continue; // Skip events we aren't trying to undo.
        var list = calls[ev], i = (list && list.length) || 0;
        while (i--) {
          var bound = list[i];
          if (bound && (!callback || callback == bound.callback) &&
            (!scope || scope == bound.scope)) {
            list[i] = null;
          }
        }
      }
    },
    
    // Remove all bound callbacks.
    unbindAll : function() {
      delete this.__callbacks__;
    },
    
    // Fire an event, triggering all bound callbacks.
    fire : function(e) {
      if (!e) throw('dc.util.Bindable: Undefined event');
      var calls = this.__callbacks__;
      
      for (var j=0; j<2; j++) {
        var ev = j ? e : dc.util.Bindable.ALL_EVENTS;
        var list = calls && calls[ev], i = (list && list.length) || 0;
        var thin = false;
        while(i--) {
          var bound = list[i];
          if (bound) {
            try {
              bound.callback.apply(this, arguments);
            } catch(except) {
              if (except == dc.util.Bindable.UNBIND) {
                list[i] = null;
                thin = true;
              } else {
                throw except;
              }
            }
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