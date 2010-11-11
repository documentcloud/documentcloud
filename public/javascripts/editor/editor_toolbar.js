dc.ui.EditorToolbar = Backbone.View.extend({

  className : 'editor_toolbar interface',

  constructor: function() {
    Backbone.View.apply(this, arguments);
    this.modes = {};
    this.viewer = currentDocument;
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },

  toggle : function() {
    if (this.modes.open == 'is') {
      this.close();
    } else {
      dc.app.editor.closeAllEditors();
      this.open();
    }
  }

});