// Read and write cookies from the browser.
dc.app.cookies = {

  // Read a cookie by name.
  read : function(name) {
    var matcher = new RegExp("\\s*" + name + "=(.*)$");
    var list    = document.cookie.split(';');
    var cookie  = _.detect(list, function(c) { return c.match(matcher); });
    return cookie ? decodeURIComponent(cookie.match(matcher)[1]) : null;
  },

  // Write a cookie's value, and keep it only for the session (default), or
  // forever (2 years).
  write : function(name, value, keep) {
    var expiration = keep ? new Date() : null;
    if (expiration) keep == 'remove' ? expiration.setYear(expiration.getFullYear() - 1) :
                                       expiration.setYear(expiration.getFullYear() + 2);
    var date = expiration ? '; expires=' + expiration.toUTCString() : '';
    document.cookie = name + '=' + encodeURIComponent(value) + '; path=/' + date;
  },

  // Remove a cookie.
  remove : function(name) {
    this.write(name, this.read(name), 'remove');
  }

};