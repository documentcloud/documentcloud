// JavaScript validation regular expressions.
dc.app.validator = {

  // Validate a string based on one of the validator regexes. For example:
  //
  //    dc.app.validator.check('http://...', 'url');
  //
  check : function(string, test) {
    return this[test].test(string);
  },

  url : /^(https?:)\/\/(www\.)?([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+([a-zA-z]{2,6})(\/[a-zA-Z0-9$_.+!#*(),;\/?:@&~=%-]*)?$/

};