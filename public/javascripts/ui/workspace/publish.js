dc.ui.Publish = dc.View.extend({

  constructor : function() {
  },

  render : function() {
    this.el = $('#publish_container')[0];
    dc.history.register(/^#publish\//,     _.bind(this.openPublishTab, this, ''));
    dc.app.navigation.bind('tab:publish',  _.bind(this.openPublishTab, this));
    this.setCallbacks();
    return this;
  },
  
  openPublishTab : function() {
    dc.app.navigation.open('publish');
    dc.history.save('publish/');
  }
  
});