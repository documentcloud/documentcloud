// A tiny object to perform string substitution for translation

// This is intended to be the simplest thing that could possibly work
// We'll build up from there as needs arise
//
// Uses the concept of translations packs
// which are JS Modules with the following form:

// var simple_pack = {
//   code: 'en',
//   nplurals: 2,
//   pluralizer: function(n){
//     return n ? 1 : 0;
//   },
//   strings: {
//     "not_found_project":"This project (%s) does not contain any documents.",
//     "no_reviewer_on_document":[
//       "The document %2$s does not have a reviewer",
//       "There are %d reviewers on document %s."
//     ]
//   }
// };
// _.i18n.load( simple_pack );

// Packs can be stacked, and lookups will fallback to earlier loaded ones.

// The typical usage pattern will be to first
//  load the English pack, then a language pack that would be relevant to the user
//

// using the above pack as an example:

// _.t('not_found_project','TestingOnly')
// returns: "This project (TestingOnly) does not contain any documents."
//
// _.t('no_reviewer_on_document',2,'GoodDoc')
// would return: "There are 2 reviewers on document GoodDoc."
// but _.t('no_reviewer_on_document',1,'GoodDoc')
// would return: "The document GoodDoc does not have a reviewer."


(function(root) {

  var _ = root._;

  if ( root.console ){
    LOG=window.console;
  } else {
    var emptyfn = function(str){ };
    LOG = {
      warn: emptyfn, error: emptyfn
    };
  }

  _.i18n = {
    packs: [],
    default:  null,
    codes: {},
    fallback: null,

    configure: function( options ){
      if ( options.default )
        this.set( 'default', options.default );
      if ( options.fallback )
        this.set( 'fallback', options.fallback );
    },

    set: function( type, code ){
      if ( ! code ) {
        code = root.DC_LANGUAGE_CODES ? root.DC_LANGUAGE_CODES[ type ] : 'eng';
      }
      this.codes[ type ] = code;
      this[ type ] = this.packForCode( code );
    },

    load: function( pack ){
      if ( _.isArray(pack) ){
        this.packs = this.packs.concat( pack );
      } else {
        this.packs.push( pack );
      }

      if ( ! this.default )
        this.set( 'default', this.codes['default'] );

      if ( ! this.fallback )
        this.set( 'fallback', this.codes['fallback'] );
    },

    packForCode: function( code ){
      return _.detect( this.packs, function( pack ){
        return pack.code == code;
      });
    }

  };

  _.t = function( key, args ){

    var match, pack;
    pack = _.i18n.default;

    if ( ! ( match = pack.strings[ key ] ) ){
      LOG.warn( '[i18n] lookup for ' + key + ' in \'' + pack.code + '\' failed.' );
      pack = _.i18n.fallback;
      if ( ! ( match = pack.strings[ key ] ) ){
        LOG.error( '[i18n] lookup for ' + key + ' failed in all languages' );
        return key;  // something is better than nothing (perhaps?)
      }
    };

    // if our matching string is an array
    // then we select the match from it using the pluralization
    // lookup rules from the pack
    if ( _.isArray( match ) ){ // plural lookup 
      match = match[ pack.pluralizer( args ) ];
    }

    return vsprintf( match, _.toArray( arguments ).slice(1) );

  };

})(this);
