// a collection of functions
// that are called by the various stages
// of the iframe login sequence

(function(window, document, $, undefined) {

  window.EmbeddedLogin = {

    // called from inner_iframe.  Opens a popup window instead of
    // attempting to load third party auth pages inside iframe since most
    // services prevent that using X-Frame-Options headers
    attachPopupHandler: function(ev){
      $('.login_services a').click( function(ev){

        ev.preventDefault();

        var POPUP_HEIGHT = 300, POPUP_WIDTH = 420,
            left = (screen.width/2)-( POPUP_WIDTH  / 2 ),
            top = (screen.height/2)-( POPUP_HEIGHT / 2 );

        var win = window.open( '/auth/omniauth_start_popup?service='+$(this).attr("href"), 'IFrameLoginPopup',
                     "menubar=no,toolbar=no,status=no,width="+ POPUP_WIDTH+",height="+POPUP_HEIGHT+
                     ",toolbar=no,left="+left+",top="+top );

        win.focus();

      } );
    },


    // These are called from inner iframe pages.
    // They communicate across the parent iframe's xdm RPC socket
    onLoginSuccess: function( account ){
      window.parent.socket.loggedInStatus({
        success: true, account: account
      });
    },
    onLoginFailure: function(){   window.parent.socket.loggedInStatus( { success:false } );                },


    // called from an omniauth powered popup window once
    // a third party login is complete.
    onPopupCompletion: function( call_type ) {
      // load success page in iframe.  It will handle informing the
      // xdm socket of the success
      window.opener.location.href= '/auth/iframe_' + call_type;
      // relay message back to iframe that opened us.
      window.close();
    },

    // this is called from the outer iframe.
    establishSocket: function(){
      // is deliberately global so child iframe can access it to send messages
      window.socket = new easyXDM.Rpc({},{
        remote: {
          // these are stubs of functions that are defined on the remote side
          loggedInStatus: {}
        },
        local: {
          loadStartingPage: function( successFn, errorFn ){
            var iframe = document.getElementById('services_login');
            iframe.contentDocument.write('<body style="background: radial-gradient(circle farthest-corner at center top , #FAFAFA 0%, #C8C8C8 100%) repeat scroll 0 0 transparent;"></body>');
            iframe.src = "/auth/inner_iframe";
          },
          getRemoteData: function(document_id,successFn,errorFn){
            $.ajax('/auth/remote_data/' + document_id, {
              success: function( data ){
                  successFn(data);
              },
              error: errorFn
            });

          }
        }
      });

    }

  };



})(window, document, jQuery);
