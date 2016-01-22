// Simplified check for browser support of features; at a certain level this 
// should be replaced with something else.
dc.app.supports = {

  css : function(selector) {
    try {
      var decoy = document.querySelector(selector);
      return true;
    } catch (e) {
      return false;
    }
  }

};
