// Account Model

dc.model.Account = dc.Model.extend({

  ADMINISTRATOR   : 1,

  CONTRIBUTOR     : 2,

  GRAVATAR_BASE   : 'http://www.gravatar.com/avatar/',

  DEFAULT_AVATAR  : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  BLANK_ACCOUNT   : {first_name : '', last_name : '', email : ''},

  constructor : function(attributes) {
    this.base(attributes || this.BLANK_ACCOUNT);
  },

  fullName : function(nonbreaking) {
    var name = this.get('first_name') + ' ' + this.get('last_name');
    return nonbreaking ? name.replace(/\s/g, '&nbsp;') : name;
  },

  isAdmin : function() {
    return this.get('role') == this.ADMINISTRATOR;
  },

  gravatarUrl : function(size) {
    var hash = this.get('hashed_email');
    var fallback = encodeURIComponent(this.DEFAULT_AVATAR);
    return this.GRAVATAR_BASE + hash + '.jpg?s=' + size + '&d=' + fallback;
  }

});

// Account Set

dc.model.AccountSet = dc.model.RESTfulSet.extend({

  resource : 'accounts',

  // Fetch the account of the logged-in journalist.
  current : function() {
    return this.get(dc.app.accountId);
  }

});

window.Accounts = new dc.model.AccountSet();
