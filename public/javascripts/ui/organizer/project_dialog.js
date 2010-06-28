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
    this.base({
      mode        : 'custom',
      title       : 'Edit Project'
    });
  },

  render : function(noHide) {
    if (!noHide) $(this.el).hide();
    this.base({editor : true, information : this.model.statistics()});
    $('.custom', this.el).html(JST.project_dialog(this.model.attributes()));
    $('#project_title', this.el).val(this.model.get('title'));
    if (!this.model.get('owner')) $('.minibutton.delete', this.el).text("Remove");
    if (this.model.collaborators.populated) {
      this._finishRender();
    } else {
      dc.ui.spinner.show();
      this.model.collaborators.populate({success : this._finishRender});
    }
    return this;
  },

  confirm : function() {
    Projects.update(this.model, {title : $('#project_title', this.el).val()});
    this.close();
  },

  _finishRender : function() {
    dc.ui.spinner.hide();
    if (this.model.collaborators.size()) {
      var views = _.map(this.model.collaborators.models(), _.bind(function(account) {
        return (new dc.ui.AccountView({model : account, kind : 'collaborator'})).render(null, {project : this.model}).el;
      }, this));
      $('.collaborator_list tbody', this.el).append(views);
      $('.collaborators', this.el).show();
    }
    $(this.el).show();
    this.center();
    this.setCallbacks();
  },

  // If we don't own it, a request to remove the project is a request to remove
  // ourselves as a collaborator.
  _deleteProject : function() {
    var wasOpen = Projects.selected()[0] == this.model;
    var finish  = function(){ if (wasOpen) dc.app.searchBox.loadDefault({clear : true}); };
    if (!this.model.get('owner')) {
      this.model.collaborators.destroy(Accounts.current(), {
        success : _.bind(function(){ Projects.remove(this.model); finish(); }, this)
      });
    } else {
      Projects.destroy(this.model, {success : finish});
    }
    this.close();
  },

  _maybeAddCollaborator : function(e) {
    if (e.keyCode == 13) this._addCollaborator();
  },

  _addCollaborator : function() {
    var email = $('#collaborator_email', this.el).val();
    if (!email) return this.error('Please enter an email address.');
    this.showSpinner();
    this.model.collaborators.create(new dc.model.Account({email : email}), null, {
      success : _.bind(function(acc, resp){ acc.set(resp); this.model.collaborators.sort(); this.model.set({collaborator_count : this.model.get('collaborator_count') + 1}); this.render(true);}, this),
      error   : _.bind(function(acc){ this.hideSpinner(); this.model.collaborators.remove(acc); this.error('No DocumentCloud account was found with that email.'); }, this)
    });
  },

  _removeCollaborator : function(e) {
    this.showSpinner();
    var collab = this.model.collaborators.get(parseInt($(e.target).attr('data-id'), 10));
    this.model.collaborators.destroy(collab, {
      success : _.bind(function(){ this.model.set({collaborator_count : this.model.get('collaborator_count') - 1}); this.render(true);}, this)
    });
  },

  _showEnterEmail : function() {
    $('.add_collaborator', this.el).hide();
    $('.enter_email', this.el).show();
    $('#collaborator_email', this.el).focus();
  }

});
