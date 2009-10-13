// A tile view for previewing a Document in a listing.
dc.ui.AccountView = dc.View.extend({
    
  AVATAR_SIZES : {
    badge : 20,
    row   : 32
  },
  
  TAGS : {
    badge : 'div',
    row   : 'tr'
  },
  
  constructor : function(account, kind) {
    this.kind       = kind;
    this.tagName    = this.TAGS[kind];
    this.className  = 'account_view ' + this.kind;
    this.base();
    this.account    = account;
    this.template   = dc.templates['ACCOUNT_' + this.kind.toUpperCase()];
  },
  
  render : function() {
    var size = this.AVATAR_SIZES[this.kind];
    var imageURL = this.account.gravatarURL(size);
    var attrs = _.extend(this.account.attributes(), {imageURL : imageURL, size : size});
    $(this.el).html(this.template(attrs));
    return this;
  },
  
  warnEmailTaken : function() {
    dc.app.notifier.show({
      text      : 'that email address is already taken',
      anchor    : $('td.email a')[0],
      position  : 'center right',
      left      : 20
    });
  }
  
});