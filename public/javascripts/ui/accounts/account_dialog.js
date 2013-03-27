dc.ui.AccountDialog = dc.ui.Dialog.extend({
  
  id : 'account_list',
  
  className : 'account_list dialog',

  events : {
    'click .ok'           : 'close',
    'click .new_account'  : 'newAccount',
    'click .language_sheet .chooser'  : 'toggleChooseLanguage',
    'click .language_sheet td' : 'chooseLanguage'
  },

  constructor : function() {
    dc.ui.Dialog.call(this, {
      mode          : 'custom',
      title         : 'Manage ' + ( Accounts.current().isAdmin() ?
                                    'Organization: ' + dc.account.organization().get('name') : 
                                    'Account' ),
      information   : 'group: ' + dc.account.organization().get('slug')
    });
    Accounts.bind('reset', _.bind(this._renderAccounts, this));
    this._rendered = false;
    this._open = false;
    $(this.el).hide();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._rendered = true;
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this._container.html(JST['account/dialog']({}));
    if (Accounts.current().isAdmin()){
      this._container.prepend( JST['account/organization_settings_dialog']({ organization: dc.account.organization().toJSON() }) );
      this.addControl(this.make('div', {'class': 'minibutton dark new_account', style : 'width: 90px;'}, 'New Account'));

    }
    this.list = this.$('.account_list_content');
    this._renderAccounts();
    return this;
  },

  open : function() {
    this._open = true;
    if (!this._rendered) {
      this.render();
      return;
    }
    $(document.body).addClass('overlay');
    this.center();
    $(this.el).show();
  },

  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
    this._open = false;
  },

  chooseLanguage: function(ev){
    target = $(ev.target);
    target.closest('table').find('td').removeClass('active');
    target.addClass('active');
    // FIXME - remove & replace with listen action on model
    // once that's hooked up
    target.closest('.language_sheet').find('.current').html( target.attr('data-lang') );
    _.delay( function(){
      target.closest('.language_sheet').removeClass('open');
    }, 500);  // wait a bit so they can see that the languages was chosen
  },

  toggleChooseLanguage: function(){
    this.$('.language_sheet').toggleClass('open')
  },

  isOpen : function() {
    return this._open;
  },

  newAccount : function() {
    var view = new dc.ui.AccountView({
      model : new dc.model.Account(), 
      kind : 'row',
      dialog : this
    });
    this.list.append(view.render('edit').el);
    this._container[0].scrollTop = this._container[0].scrollHeight;
  },

  _renderAccounts : function() {
    dc.ui.spinner.hide();
    var views = Accounts.map(function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'row'})).render().el;
    });
    this.list.append(views);
    $(this.el).show();
    this.center();
  }

});
