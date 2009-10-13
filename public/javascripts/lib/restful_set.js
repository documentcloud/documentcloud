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
  create : function(model) {
    $.ajax({
      url       : '/' + this.resource,
      type      : 'POST',
      data      : model.attributes(),
      dataType  : 'json'
      // success   : function(attributes) { model.set(attributes); }
    });
    this.add(model);
  },
  
  // Destroy a model on the server and remove it from the set.
  destroy : function(model) {
    $.ajax({
      url       : '/' + this.resource + '/' + model.id,
      type      : 'POST',
      data      : {_method : 'delete'},
      dataType  : 'json'
    });
    this.remove(model);
  },
  
  // Update a model on the server and (optionally) the client.
  // Pass only a model to persist its current attributes to the server.
  update : function(model, attributes) {
    var changeAttributes = !!attributes;
    attributes = attributes || model.attributes();
    $.ajax({
      url       : '/' + this.resource + '/' + model.id,
      type      : 'POST',
      data      : _.extend(attributes, {_method : 'put'}),
      dataType  : 'json'
    });
    if (changeAttributes) model.set(attributes);
  }
    
});