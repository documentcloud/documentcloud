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

        var POPUP_HEIGHT = 450, POPUP_WIDTH = 400,
            left = (screen.width/2)-( POPUP_WIDTH  / 2 ),
            top = (screen.height/2)-( POPUP_HEIGHT / 2 );
        var url = '/auth/omniauth_start_popup?service='+$(this).attr("href");
        var win = window.open( url, 'IFrameLoginPopup',
                               "menubar=no,toolbar=no,status=no,width="+ POPUP_WIDTH+",height="+POPUP_HEIGHT+
                               ",toolbar=no,left="+left+",top="+top );
        if ( win.focus ) {
          win.focus();
        }
      } );
    },


    // called from an omniauth powered popup window once
    // a third party login is complete.
    onPopupCompletion: function() {
      // load success page in iframe.  It will handle informing the
      // xdm socket of the success
      // If IE fails here while complaining that window.opener is null, check security zones and
      // Make sure the site isn't 'trusted'.
      // http://stackoverflow.com/questions/6190879/window-opener-becomes-null-in-internet-explorer-after-security-zone-change
      // the Timeout is another IE compatability hack.  Without it postmessage fails with XDM
      setTimeout( function(){
        window.opener.location.href= '/auth/iframe_success';
        window.close();
      }, 1 );
    },


    // These are called from inner iframe pages.
    // They communicate across the parent iframe's xdm RPC socket
    setLoginStatus: function( status, data ){
      window.parent.socket.loggedInStatus({
        status: status, data: data
      });
    },

    setIFrameSrc: function(url){
      var iframe = document.getElementById('services_login');
      // show something immediatly while page is loading
      iframe.contentDocument.write('<body style="background: radial-gradient(circle farthest-corner at center top , #FAFAFA 0%, #C8C8C8 100%) repeat scroll 0 0 transparent;"></body>');
      iframe.src = url;
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
          logout: function( document_id, successFn, errorFn ){
            EmbeddedLogin.setIFrameSrc("/auth/iframe_logout?document_id=" + document_id);
          },
          loadLoginStartingPage: function( document_id, successFn, errorFn ){
            EmbeddedLogin.setIFrameSrc("/auth/inner_iframe?document_id=" + document_id);
          },
          getRemoteData: function(document_id,successFn,errorFn){
            $.ajax('/auth/remote_data/' + document_id, {
              success: successFn,
              error: errorFn
            });

          }
        }
      });

    }

  };



})(window, document, jQuery);
