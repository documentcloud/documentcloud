// RESTful sets must specify a 'resource'.
// create   => POST     /resource
// destroy  => DELETE   /resource/id
// update   => PUT      /resource/id
dc.model.RESTfulSet = dc.Set.extend({
  
  // TODO: Think about if it makes sense to implement 'read'.
  
  // TODO: Think about if we care about server responses, and if so, success
  // and failure.
  
  constructor : function() {
    if (!this.resource) throw new Error('dc.model.RESTfulSet: Unspecified resource');
    this.base();
  },
  
  // Create a model on the server and add it to the set.
  // When the server returns a JSON representation of the model, we update it
  // on the client.
  create : function(model, attributes, options) {
    options = options || {};
    if (attributes) model.set(attributes);
    if (!this.include(model)) this.add(model);
    $.ajax({
      url       : '/' + this.resource,
      type      : 'POST',
      data      : model.attributes(),
      dataType  : 'json',
      success   : _.bind(this._handleSuccess, this, model, options.success),
      error     : _.bind(this._handleError, this, model, options.error)
    });
  },
  
  // Destroy a model on the server and remove it from the set.
  destroy : function(model, options) {
    options = options || {};
    this.remove(model);
    $.ajax({
      url       : '/' + this.resource + '/' + model.id,
      type      : 'POST',
      data      : {_method : 'delete'},
      dataType  : 'json',
      success   : function(resp) { if (options.success) options.success(model, resp); },
      error     : _.bind(this._handleError, this, model, options.error)
    });
  },
  
  // Update a model on the server and (optionally) the client.
  // Pass only a model to persist its current attributes to the server.
  update : function(model, attributes, options) {
    options = options || {};
    if (attributes) model.set(attributes);
    $.ajax({
      url       : '/' + this.resource + '/' + model.id,
      type      : 'POST',
      data      : _.extend(model.attributes(), {_method : 'put'}),
      dataType  : 'json',
      success   : _.bind(this._handleSuccess, this, model, options.success),
      error     : _.bind(this._handleError, this, model, options.error)
    });
  },
  
  _handleSuccess : function(model, callback, resp) {
    if (callback) return callback(model, resp);
    model.set(resp);
  },
  
  _handleError : function(model, callback, resp) {
    var json = eval('(' + resp.responseText + ')');
    if (callback) return callback(model, json);
    dc.ui.notifier.show({text : json.errors[0]});
  }
    
});