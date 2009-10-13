dc.model.Account = dc.Model.extend({
  
  GRAVATAR_BASE  : 'http://www.gravatar.com/avatar/',
  
  DEFAULT_AVATAR : location.protocol + '//' + location.host + '/images/icons/user_blue_32.png',
  
  BLANK_ACCOUNT : {first_name : '', last_name : '', email : ''},
  
  constructor : function(attributes) {
    this.base(attributes || this.BLANK_ACCOUNT);
  },
  
  fullName : function(nonbreaking) {
    var name = this.get('first_name') + ' ' + this.get('last_name');
    return nonbreaking ? name.replace(/\s/g, '&nbsp;') : name;
  },
  
  gravatarURL : function(size) {
    var hash = this.get('hashed_email');
    var fallback = encodeURIComponent(this.DEFAULT_AVATAR);
    return this.GRAVATAR_BASE + hash + '.jpg?s=' + size + '&d=' + fallback;
  }
  
});