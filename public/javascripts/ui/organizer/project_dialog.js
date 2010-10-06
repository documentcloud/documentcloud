dc.ui.ProjectDialog = dc.ui.Dialog.extend({

  id : 'project_dialog',

  callbacks : {
    '.ok.click'                     : 'confirm',
    '.cancel.click'                 : 'close',
    '.delete.click'                 : '_deleteProject',
    '.add_collaborator.click'       : '_showEnterEmail',
    '.minibutton.add.click'         : '_addCollaborator',
    '#collaborator_email.keypress'  : '_maybeAddCollaborator',
    '.remove.click'                 : '_removeCollaborator'
  },

  constructor : function(options) {
    _.bindAll(this, '_finishRender');
    this.model = options.model;
    dc.ui.Dialog.call(this, {
      mode        : 'custom',
      title       : 'Edit Project'
    });
  },

  render : function(noHide) {
    if (!noHide) $(this.el).hide();
    dc.ui.Dialog.prototype.render.call(this, {editor : true, information : this.model.statistics()});
    this.$('.custom').html(JST['organizer/project_dialog']({model : this.model}));
    this.$('#project_title').val(this.model.get('title'));
    if (!this.model.get('owner')) this.$('.minibutton.delete').text("Remove");
    if (this.model.collaborators.length) {
      this._finishRender();
    } else {
      dc.ui.spinner.show();
      this.model.collaborators.fetch({success : this._finishRender});
    }
    return this;
  },

  confirm : function() {
    var title = this.$('#project_title').val();
    if (!title) return this.error("Please specify a project title.");
    this.model.save({title : title});
    this.close();
  },

  _finishRender : function() {
    dc.ui.spinner.hide();
    if (this.model.collaborators.length) {
      var views = this.model.collaborators.map(_.bind(function(account) {
        return (new dc.ui.AccountView({model : account, kind : 'collaborator'})).render(null, {project : this.model}).el;
      }, this));
      this.$('.collaborator_list tbody').append(views);
      this.$('.collaborators').show();
    }
    $(this.el).show();
    this.center();
  },

  // If we don't own it, a request to remove the project is a request to remove
  // ourselves as a collaborator.
  _deleteProject : function() {
    var wasOpen = Projects.selected()[0] == this.model;
    if (!this.model.get('owner')) {
      Projects.remove(this.model);
      this.model.collaborators.current().destroy();
    } else {
      this.model.destroy();
    }
    this.close();
    if (wasOpen && !dc.app.searcher.flags.outstandingSearch) {
      dc.app.searcher.loadDefault({clear : true});
    }
  },

  _maybeAddCollaborator : function(e) {
    if (e.keyCode == 13) this._addCollaborator();
  },

  _addCollaborator : function() {
    var email = this.$('#collaborator_email').val();
    if (!email) return this.error('Please enter an email address.');
    this.showSpinner();
    this.model.collaborators.create({email : email}, {
      success : _.bind(function(acc, resp) {
        this.model.set({collaborator_count : this.model.get('collaborator_count') + 1});
        this.render(true);
      }, this),
      error   : _.bind(function(acc) {
        this.hideSpinner();
        this.error('No DocumentCloud account was found with that email.');
      }, this)
    });
  },

  _removeCollaborator : function(e) {
    this.showSpinner();
    var collab = this.model.collaborators.get(parseInt($(e.target).attr('data-id'), 10));
    collab.destroy({
      success : _.bind(function(){ this.model.set({collaborator_count : this.model.get('collaborator_count') - 1}); this.render(true);}, this)
    });
  },

  _showEnterEmail : function() {
    this.$('.add_collaborator').hide();
    this.$('.enter_email').show();
    this.$('#collaborator_email').focus();
  }

});
