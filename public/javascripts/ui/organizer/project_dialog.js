dc.ui.ProjectDialog = dc.ui.Dialog.extend({

  id : 'project_dialog',

  callbacks : {
    '.ok.click'                     : 'confirm',
    '.cancel.click'                 : 'close',
    '.delete.click'                 : '_deleteProject',
    '.add_collaborator.click'       : '_showEnterEmail',
    '.minibutton.add.click'         : '_addCollaborator',
    '#collaborator_email.keypress'  : '_maybeAddCollaborator'
  },

  constructor : function(options) {
    this.model = options.model;
    this.base({
      mode        : 'custom',
      title       : 'Edit Project'
    });
  },

  render : function() {
    this.base({editor : true, information : this.model.statistics()});
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
  },

  _maybeAddCollaborator : function(e) {
    if (e.keyCode == 13) this._addCollaborator();
  },

  _addCollaborator : function() {
    var email = $('#collaborator_email', this.el).val();
    if (!email) return this.error('Please enter an email address.');
    this.showSpinner();
    this.model.addCollaborator(email, _.bind(this.render, this), _.bind(function(response) {
      this.hideSpinner();
      this.error(response.responseText);
    }, this));
  },

  _showEnterEmail : function() {
    $('.add_collaborator', this.el).hide();
    $('.enter_email', this.el).show();
    $('#collaborator_email', this.el).focus();
  }

});
