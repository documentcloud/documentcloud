dc.ui.ProjectDialog = dc.ui.Dialog.extend({

  id : 'project_dialog',

  callbacks : {
    '.ok.click'      : 'confirm',
    '.cancel.click'  : 'close',
    '.delete.click'  : '_deleteProject'
  },

  constructor : function(options) {
    this.model = options.model;
    this.base({
      mode   : 'custom',
      title  : 'Edit Project'
    });
  },

  render : function() {
    this.base({editor : true});
    $('.custom', this.el).html(JST.project_dialog(this.model.attributes()));
    this.setCallbacks();
    return this;
  },

  confirm : function() {
    Projects.update(this.model, {title : $('#project_title', this.el).val()});
    this.close();
  },

  _deleteProject : function() {
    Projects.destroy(this.model);
    this.close();
  }

});
