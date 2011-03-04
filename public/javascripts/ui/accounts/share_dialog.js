dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id                    : 'share_dialog',
  className             : 'account_list dialog',

  events : {
    'click .close':                            'close',
    'click .next':                             '_nextStep',
    'click .previous':                         '_previousStep',
    'click .add_reviewer':                     '_showEnterEmail',
    'click .cancel_add':                       '_cancelAddReviewer',
    'click .minibutton.add':                   '_submitAddReviewer',
    'click .remove_reviewer':                  '_removeReviewer',
    'click .resend_reviewer':                  '_resendInstructions',
    'click .show_custom_email':                '_showCustomEmail',
    'click .hide_custom_email':                '_hideCustomEmail',
    'keypress .reviewer_management_email':     '_maybeAddReviewer',
    'keypress .reviewer_management_firstname': '_maybeAddReviewer',
    'keypress .reviewer_management_lastname':  '_maybeAddReviewer'
  },

  STEP_TITLES : [
    "",
    "Email Your Reviewers"
  ],

  initialize : function(options) {
    _.bindAll(this, '_renderReviewers', '_refreshReviewers', '_cancelAddReviewer',
                    '_onAddSuccess', '_onAddError', '_onRemoveSuccess', '_onRemoveError',
                    '_showEnterEmail', '_nextStep');
    this.renderedAccounts = {};
    this._boundRender     = [];
    this.currentStep      = 1;
    this.newReviewers     = [];
    this.accountsToEmail  = new dc.model.AccountSet();
    this.docs             = new dc.model.DocumentSet(options.docs);

    $(this.el).hide().empty();
    dc.ui.spinner.show();
    this.fetchReviewers();

    if (this.docs.all(function(doc) { return doc.get('reviewers_count') == 0; })) {
      this.renderEmailDialog();
    }
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this.setMode('share', 'dialog');
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this._container.html(JST['account/share_dialog']({
      'defaultAvatar' : dc.model.Account.prototype.DEFAULT_AVATAR,
      'docCount': this.docs.length
    }));
    this._next     = this.$('.next');
    this._previous = this.$('.previous');
    $(document.body).addClass('overlay');
    $(this.el).show();
    dc.ui.spinner.hide();
    this._setPlaceholders();
    this._setStep();
    this._enabledNextButton();
    return this;
  },

  renderEmailDialog : function() {
    var docSize = this.docs.length;
    var title = [
      'Share ',
      (this.docs.length == 1 ?
        '\"' + Inflector.trim(this.docs.first().get('title'), 30) + '\"' :
        this.docs.length + ' Documents'),
      ' With Reviewers'
    ].join('');

    this.showingEmailDialog = true;
    dc.ui.spinner.hide();

    dc.ui.Dialog.prompt(title, '', _.bind(function(email) {
      this.showingEmailDialog = false;
      this._renderReviewers();
      this._showEnterEmail();
      this._focusEmail(email);
      this._submitAddReviewer();
      return true;
    }, this), {
        mode:        'short_prompt',
        description: 'Start with the email address of your first reviewer:',
        saveText:    'Next',
        closeText:   'Cancel'
    });
  },

  close : function() {
    this.accountsToEmail.each(function(account) {
      account.set({needsEmail: false});
    });
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  },

  // =======================
  // = Rendering Reviewers =
  // =======================

  fetchReviewers : function() {
    $.ajax({
      url : '/reviewers',
      type : 'GET',
      data : {document_ids: this.docs.pluck('id')},
      success: this._refreshReviewers,
      error : this._renderReviewers
    });
  },

  _refreshReviewers : function(resp) {
    this.emailBody = resp.email_body.replace(/\n+/g, '<p>');

    if (this.showingEmailDialog) return;

    _.each(resp.reviewers, _.bind(function(reviewers, document_id) {
      this.docs.get(document_id).reviewers.refresh(reviewers);
    }, this));
    this._renderReviewers();
  },

  _renderReviewers : function() {
    this.render();
    var views = [];
    // this.commonReviewers = Documents.sharedReviewers(this.docs);
    this._countDocuments();
    this.renderedAccounts = {};
    this.docs.each(_.bind(function(doc) {
      doc.reviewers.each(_.bind(function(account) {
        var accountView = this._renderReviewer(account);
        if (accountView) views.push(accountView);
      }, this));
    }, this));

    this.$('.account_list tr:not(.reviewer_management)').remove();
    this.$('.account_list').prepend(views);
    this.$('.document_reviewers_empty').toggle(!_.keys(this.renderedAccounts).length);
    this._cancelAddReviewer();
    this.center();
  },

  _setPlaceholders : function() {
    this.$('input[name=first_name], input[name=last_name]').placeholder();
    this.$('input[name=email]').placeholder();
  },

  _countDocuments : function() {
    this.accountDocumentCounts = {};
    this.docs.each(_.bind(function(doc) {
      doc.reviewers.each(_.bind(function(account) {
        if (this.accountDocumentCounts[account.id]) {
          this.accountDocumentCounts[account.id] += 1;
        } else {
          this.accountDocumentCounts[account.id] = 1;
        }
      }, this));
    }, this));
  },

  _renderReviewer : function(account) {
    if (account.id in this.renderedAccounts) return;

    var view = new dc.ui.AccountView({
      model  : account,
      kind   : 'reviewer',
      dialog : this
    });

    view.render('display', {
      isReviewer     : !_.contains(dc.model.Account.COLLABORATOR_ROLES, account.get('role')),
      documentCount  : this.accountDocumentCounts[account.id],
      documentsCount : this.docs.length
    });

    account.bind('change:needsEmail', _.bind(this._showReviewersToEmail, this));
    account.bind('change:needsEmail', _.bind(this._enabledNextButton, this));
    account.bind('change:needsEmail', _.bind(this._rerenderReviewer, this, account));

    this.renderedAccounts[account.id] = view;
    this._observeReviewer(account, view);

    return view.el;
  },

  _rerenderReviewer : function(account) {
    this.renderedAccounts[account.id].render('display', {
      isReviewer     : !_.contains(dc.model.Account.COLLABORATOR_ROLES, account.get('role')),
      documentCount  : this.accountDocumentCounts[account.id],
      documentsCount : this.docs.length
    });
  },

  _observeReviewer : function(account, view) {
    account.unbind('change', view._boundRender);
    if (this._boundRender[account.id]) account.unbind('change', this._boundRender[account.id]);
    this._boundRender[account.id] = _.bind(this._rerenderReviewer, this, account);
    account.bind('change', this._boundRender[account.id]);
  },

  // ==================================
  // = Add/Remove Reviewer Management =
  // ==================================

  _showEnterEmail : function() {
    if (this.showingManagement) return this._submitAddReviewer(this._showEnterEmail);

    this.showingManagement = true;
    this.$('.reviewer_management').show();
    this.$('.document_reviewers_empty').hide();
    this._focusEmail();
    this._enabledNextButton();
  },

  _focusEmail : function(email) {
    var $reviewers = this.$('.document_reviewers');
    $reviewers.attr('scrollTop', $reviewers.attr("scrollHeight")+100);
    this.$('.reviewer_management input[name=email]').focus();
    if (email) this.$('.reviewer_management input[name=email]').val(email);
  },

  _cancelAddReviewer : function() {
    this.showingManagement = false;
    this.$('.reviewer_management').hide();
    this.$('.reviewer_management input').val('');
    this.$('.document_reviewers_empty').toggle(!_.keys(this.renderedAccounts).length);
    this._enabledNextButton();
  },

  _maybeAddReviewer : function(e) {
    // Try to add reviewer on `enter` key
    if (e.keyCode == 13) this._submitAddReviewer();
  },

  _submitAddReviewer : function(callback, dismiss_empty) {
    var email = this.$('.reviewer_management input[name=email]').val();
    if (!email.length && this.accountsToEmail.length && dismiss_empty) {
      this._cancelAddReviewer();
      return callback();
    }
    if (!email.length) {
      this._focusEmail();
      return this.$('.reviewer_management .error').text('Please enter an email address.');
    }

    this.showSpinner();
    $.ajax({
      url : '/reviewers',
      type : 'POST',
      data : {
        email         : Inflector.trim(email),
        first_name    : Inflector.trim(this.$('.reviewer_management input[name=first_name]').val()),
        last_name     : Inflector.trim(this.$('.reviewer_management input[name=last_name]').val()),
        document_ids  : this.docs.pluck('id')
      },
      success: _.bind(function(resp) { this._onAddSuccess(resp, callback); }, this),
      error : this._onAddError
    });
  },

  _onAddSuccess : function(resp, callback) {
    _.each(resp.documents, function(doc) {
      Documents.get(doc.id).set(doc);
    });
    var newAccount = new dc.model.Account(resp.account);
    this.docs.each(_.bind(function(doc) {
      var account = doc.reviewers.get(newAccount.id);
      if (!account) {
        newAccount.set({needsEmail: true});
        doc.reviewers.add(newAccount);
      } else {
        account.set({needsEmail: true});
      }
    }, this));
    this.showingManagement = false;
    this._renderReviewers();
    if (callback) callback();
    this._enabledNextButton();
  },

  _onAddError : function(resp) {
    var status = resp.status;
    var $error = this.$('.reviewer_management .error').removeClass('error_white');

    resp = JSON.parse(resp.responseText);
    if (resp.errors && _.any(resp.errors, function(error) {
      error = error.toLowerCase();
      return error.indexOf("first name") != -1 || error.indexOf("last name") != -1;
    })) {
      this._showReviewerNameInputs();
      $error.text("Please provide the reviewer's full name.").addClass('error_white');
    } else if (resp.errors) {
      $error.text(resp.errors[0]);
    } else if (status == 403) {
      this.error('You are not allowed to add reviewers.');
    } else {
      $error.text("Please enter in the email address of a reviewer.");
    }
    this.hideSpinner();
    this._focusEmail();
    this._enabledNextButton();
  },

  _showReviewerNameInputs : function() {
    this.$('input[name=first_name], input[name=last_name]').show();
    this.$('.enter_full_name_label').show();
    this.$('.enter_email_label').hide();
    this._setPlaceholders();
  },

  _removeReviewer : function(e) {
    this.showSpinner();
    var accountId = parseInt($(e.target).attr('data-account-id'), 10);
    var accounts  = _.flatten(this.docs.map(function(doc){ return doc.reviewers.models; }));
    var account   = _.detect(accounts, function(acc){ return acc.id == accountId; });
    var reviewerDocuments = this.docs.select(function(doc) {
      return doc.reviewers.any(function(r) { return r.get('id') == account.get('id'); });
    });
    var documentIds = _.map(reviewerDocuments, function(d) { return d.get('id'); });

    $.ajax({
      url : '/reviewers/' + accountId,
      type : 'DELETE',
      data : {
        account_id : accountId,
        document_ids : documentIds
      },
      success: _.bind(function(resp) {
        this._onRemoveSuccess(resp, documentIds, account);
      }, this),
      error : this._onRemoveError
    });
    this._enabledNextButton();
  },

  _onRemoveSuccess : function(resp, documentIds, account) {
    _.each(resp, function(doc) {
      Documents.get(doc.id).set(doc);
    });
    this.docs.each(_.bind(function(doc) {
      if (_.contains(documentIds, doc.id)) {
        doc.reviewers.remove(account);
      }
    }, this));
    dc.ui.notifier.show({
      text      : account.get('email') + ' is no longer a reviewer on ' + documentIds.length + Inflector.pluralize(' document', documentIds.length),
      duration  : 5000,
      mode      : 'info'
    });
    this._renderReviewers();
    this._enabledNextButton();
  },

  _onRemoveError : function(resp) {
    this.hideSpinner();
     if (resp.status == 403) {
      this.error('You are not allowed to remove reviewers.');
    } else {
      this.error('There was a problem removing the reviewer.');
    }
    this._enabledNextButton();
  },

  _resendInstructions : function(e) {
    var accountId = parseInt($(e.target).attr('data-account-id'), 10);
    this.docs.each(function(doc) {
      doc.reviewers.each(function(account) {
        if (account.id == accountId) account.set({needsEmail: true});
      });
    });

    this._enabledNextButton();
    this._nextStep();
  },

  // ====================
  // = Step Two: Emails =
  // ====================

  _showReviewersToEmail : function() {
    this.accountsToEmail.refresh();
    var $list = this.$('.email_reviewers_list').empty();

    this.docs.each(_.bind(function(doc) {
      doc.reviewers.each(_.bind(function(account) {
        if (account.get('needsEmail') && !this.accountsToEmail.get(account.id)) {
          this.accountsToEmail.add(account);
          var view = (new dc.ui.AccountView({
            model : account,
            kind : 'reviewer_email',
            dialog: this
          })).render('display');
          $list.append(view.el);
        }
      }, this));
    }, this));

    this._setupEmailBody();
  },

  _showCustomEmail : function() {
    var $custom = this.$('.custom_message');
    $custom.show();
    this.$('.step_two').setMode('is', 'custom_email');
  },

  _hideCustomEmail : function() {
    var $custom = this.$('.custom_message');
    $custom.hide();
    this.$('.step_two').setMode('not', 'custom_email');
    this.$('.email_message textarea').val('');
  },

  _setupEmailBody : function() {
    var $body           = this.$('.email_message_body');
    var $textContainer  = this.$('.email_message_text_container');
    var $container      = this.$('.email_message');
    var body            = this.emailBody;
    $textContainer.appendTo($container);

    $body.empty();
    $body.html(body);
    var $message = this.$('.custom_message');
    $textContainer.appendTo($message);
    this._hideCustomEmail();
  },

  _sendInstructions : function() {
    var accounts = this.accountsToEmail;
    this.showSpinner();

    this._next.setMode('not', 'enabled');
    this._next.html('Sending...');

    var documents = this.docs.select(function(doc) {
      return doc.reviewers.any(function(r) { return accounts.get(r.get('id')); });
    });
    var documentIds = _.pluck(documents, 'id');
    var accountIds  = accounts.pluck('id');
    var message = $.trim(this.$('.email_message_text').val());

    $.ajax({
      url : '/reviewers/send',
      type : 'POST',
      data : {
        account_ids   : accountIds,
        document_ids  : documentIds,
        message       : Inflector.trim(message)
      },
      success: _.bind(function(resp) {
        var text = [
          'Instructions for reviewing ',
          documentIds.length == 1 ?
            '\"' + Inflector.truncate(this.docs.get(documentIds[0]).get('title'), 30, '...') + '\"' :
            documentIds.length + ' documents',
          ' sent to ',
          accounts.length == 1 ?
            accounts.first().get('email'):
            accounts.length + ' people',
          '.'
        ].join('');
        dc.ui.notifier.show({
          text     : text,
          duration : 5000,
          mode     : 'info'
        });

        accounts.each(function(account) {
          account.set({needsEmail: false});
        });
        this.hideSpinner();
        this.close();
      }, this),
      error : _.bind(function(resp) {
        this.hideSpinner();
        this.error('Your instructions were not sent. Contact support for help troubleshooting sharing.');
        this._setStep();
        this._enabledNextButton();
      }, this)
    });
  },

  // =========
  // = Steps =
  // =========

  _enabledNextButton : function() {
    var newAccounts = this.docs.any(function(doc) {
      return doc.reviewers.any(function(account) {
        return account.get('needsEmail');
      });
    });

    this._next.setMode(newAccounts || this.showingManagement ? 'is' : 'not', 'enabled');
  },

  _setStep : function() {
    var title = this._displayTitle();
    this.title(title);
    var last = this.currentStep == this.STEP_TITLES.length;

    this._next.html(last ? 'Finish' : 'Next &raquo;');
    this.setMode('p'+this.currentStep, 'step');

    if (this.currentStep == 2) {
      this._showReviewersToEmail();
    }
  },

  _displayTitle : function() {
    var title = '';

    if (this.currentStep == 1) {
      title = this.docs.length == 1 ?
              'Sharing "' + Inflector.truncate(this.docs.first().get('title'), 30) + '"' :
              'Sharing ' + this.docs.length + ' Documents';
    }
    return this.STEP_TITLES[this.currentStep-1] + title;
  },

  _nextStep : function() {
    if (this.showingManagement) return this._submitAddReviewer(this._nextStep, true);
    if (this.currentStep >= this.STEP_TITLES.length) {
      this._sendInstructions();
    } else {
      this.currentStep += 1;
      this._setStep();
    }
  },

  _previousStep : function() {
    if (this.currentStep > 1) this.currentStep -= 1;
    this._setStep();
  }

});
