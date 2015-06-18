function post(url, params) {
  var req = new XMLHttpRequest();
  req.open('POST', url);
  req.send(params);
}


window.pushCallbacks = {
  // success callback for PushNotification.setApplicationIconBadgeNumber
  successHandler: function(result) {},

  // error callback for PushNotification.setApplicationIconBadgeNumber
  errorHandler: function(error) {},

  sendTokenToServer: function(platform, token) {
    var postUrl = 'http://alerts.homeclub.us/devices';
    var params = 'platform=' + platform + '&token=' + token;

    post(postUrl, params);

    localStorage.setItem(platform + '_token', token);
  }
};


pushCallbacks.APN = {
  onNotification: function(event) {
    if(event.alert) {
      //alert(event.alert);
    }

    if(event.sound) {
      var snd = new Media(event.sound);
      snd.play();
    }

    if(event.badge) {
      pushNotification.setApplicationIconBadgeNumber(pushCallbacks.successHandler, pushCallbacks.errorHandler, event.badge);
    }
  },

  successfulRegistration: function(token) {
    pushCallbacks.sendTokenToServer('iPhone', token);
  }
};


pushCallbacks.GCM = {
  onNotification: function(e) {
    switch(e.event) {
      case 'registered':
        var token = e.regid;

        if(token.length) {
          pushCallbacks.sendTokenToServer('Android', token);
        }
        break;

      case 'message':
        if(e.foreground) {
          //alert('foreground message');
        } else {
          if(e.coldstart) {
            //alert('coldstart message');
          } else {
            //alert('hotstart message');
          }
        }
        break;

      case 'error':
        alert('GCM error: ' + e.msg);
        break;

      default:
        alert('An unknown GCM error has occured');
        break;
    }
  },

  successfulRegistration: function(id) {}
};