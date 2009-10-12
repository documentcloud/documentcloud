dc.model.Account = dc.Model.extend({
  
  GRAVATAR_BASE  : 'http://www.gravatar.com/avatar/',
  
  DEFAULT_AVATAR : location.protocol + '//' + location.host + '/images/icons/user_blue_32.png',
  
  gravatarURL : function(size) {
    var hash = this.get('hashed_email');
    var fallback = encodeURIComponent(this.DEFAULT_AVATAR);
    return this.GRAVATAR_BASE + hash + '.jpg?s=' + size + '&d=' + fallback;
  }
  
});