// A tile view for previewing a Document in a listing.
dc.ui.AccountBadge = dc.View.extend({
  
  className : 'account_badge',
  
  AVATAR_SIZE : 20,
  
  constructor : function(account) {
    this.account = account;
    this.base();
  },
  
  render : function() {
    var size = this.AVATAR_SIZE;
    var imageURL = this.account.gravatarURL(size);
    var attrs = _.extend(this.account.attributes(), {imageURL : imageURL, size : size});
    $(this.el).html(dc.templates.ACCOUNT_BADGE(attrs));
    return this;
  }
  
});