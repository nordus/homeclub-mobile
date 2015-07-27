// Generated by CoffeeScript 1.8.0
(function() {
  var baseUrl, meta, services;

  services = angular.module('hcMobile.services', []);

  baseUrl = 'http://homeclub.us/api';

  meta = {
    "sensorHubTypes": {
      "1": "Water Detect",
      "2": "Indoor Climate",
      "3": "Item Movement",
      "4": "Human Motion"
    },
    "roomTypes": {
      '53a89614993d0c750d0fe2da': 'bedroom',
      '53a89614993d0c750d0fe2df': 'living room',
      '53a89614993d0c750d0fe2db': 'other',
      '53a89614993d0c750d0fe2dd': 'hallway',
      '53a89614993d0c750d0fe2e4': 'family room',
      '53a89614993d0c750d0fe2e0': 'master bedroom',
      '53a89614993d0c750d0fe2e9': 'basement',
      '53a89614993d0c750d0fe2e2': 'laundry room',
      '53a89614993d0c750d0fe2e5': 'kitchen',
      '53a89614993d0c750d0fe2e7': 'entryway',
      '53a89614993d0c750d0fe2e8': 'office',
      '53a89614993d0c750d0fe2ea': 'bathroom',
      '53a89614993d0c750d0fe2e6': 'dining room',
      '548f99ace4b072ab145ace8f': 'garage'
    },
    "waterSources": {
      '548f9b03e4b072ab145ace92': 'aquarium',
      '548f9b27e4b072ab145ace93': 'bath tub',
      '548f9b3fe4b072ab145ace94': 'dishwasher',
      '548f9b52e4b072ab145ace95': 'humidifier',
      '548f9b5ee4b072ab145ace96': 'other',
      '548f9b93e4b01c12d0145521': 'shower',
      '548f9b9de4b01c12d0145522': 'sink',
      '548f9bade4b01c12d0145523': 'sump pump',
      '548f9bb8e4b01c12d0145524': 'toilet',
      '548f9bc2e4b01c12d0145526': 'washing machine',
      '548f9bd8e4b01c12d0145529': 'water heater',
      '548f9be8e4b01c12d014552a': 'water pipe'
    }
  };

  services.factory('SessionFactory', function($window) {
    var _sessionFactory;
    _sessionFactory = {};
    _sessionFactory.createSession = function(user) {
      $window.localStorage.user = JSON.stringify(user);
      return $ionicPlatform.ready(function() {
        if (analytics) {
          console.log('.. startTrackerWithId()');
          analytics.startTrackerWithId('UA-50394594-4');
          analytics.setUserId(user._id);
          analytics.addCustomDimension('dimension1', user._id);
          analytics.addCustomDimension('dimension2', user.carrier);
          return analytics.trackView('/login');
        } else {
          return console.log('.. could not set Google Analytics custom dimensions :( ');
        }
      });
    };
    _sessionFactory.getSession = function() {
      return JSON.parse($window.localStorage.user);
    };
    _sessionFactory.deleteSession = function() {
      delete $window.localStorage.user;
      return true;
    };
    _sessionFactory.checkSession = function() {
      if ($window.localStorage.user) {
        return true;
      }
      return false;
    };
    _sessionFactory.setRoomNames = function(sensorHubs) {
      var currentUser;
      if (sensorHubs == null) {
        sensorHubs = [];
      }
      currentUser = JSON.parse($window.localStorage.user);
      currentUser.roomNamesBySensorHubMacAddress = {};
      sensorHubs.forEach(function(sensorHub) {
        return this[sensorHub._id] = meta.sensorHubTypes[String(sensorHub.sensorHubType)];
      }, currentUser.roomNamesBySensorHubMacAddress);
      return $window.localStorage.user = JSON.stringify(currentUser);
    };
    return _sessionFactory;
  });

  services.factory('AuthFactory', function($http) {
    var _authFactory;
    _authFactory = {};
    _authFactory.login = function(user) {
      return $http.post(baseUrl + '/login', user);
    };
    return _authFactory;
  });

  services.factory('latest', function($resource) {
    return $resource(baseUrl + '/latest/sensor-hub-events');
  });

  services.factory('sensorhub', function($resource) {
    return $resource(baseUrl + '/sensor-hubs/:id', {
      id: '@_id'
    }, {
      update: {
        method: 'PUT'
      }
    });
  }).factory('customeraccount', function($resource) {
    return $resource(baseUrl + '/customer-accounts/:id', {
      id: '@_id'
    }, {
      update: {
        method: 'PUT'
      }
    });
  });

  services.factory('meta', function() {
    return meta;
  });

  services.factory('alerttext', function($filter) {
    return {
      sensorHubEvent: function(message) {
        var alertText, eventDate, eventResolved, eventType;
        eventDate = $filter('date')(message.timestamp, 'MMM d h:mm a');
        eventResolved = message.sensorEventEnd !== 0;
        if (eventResolved) {
          eventType = message.sensorEventEnd;
        } else {
          eventType = message.sensorEventStart;
        }
        alertText = (function() {
          switch (eventType) {
            case 1:
              return '<i class="icon ion-waterdrop"></i> Water detect';
            case 2:
              return '<i class="icon ion-eye"></i> Motion detect';
            case 3:
              return '<i class="icon ion-thermometer"></i> Low temperature';
            case 4:
              return '<i class="icon ion-thermometer"></i> High temperature';
            case 5:
              return '<i class="icon ion-ios-rainy"></i> Low humidity';
            case 6:
              return '<i class="icon ion-ios-rainy"></i> High humidity';
            case 7:
              return '<i class="icon ion-lightbulb"></i> Low light';
            case 8:
              return '<i class="icon ion-lightbulb"></i> High light';
            case 9:
              return '<i class="icon ion-reply-all"></i> Movement';
          }
        })();
        if (eventResolved) {
          alertText += ' resolved';
        }
        alertText += " <span class='small-text'>" + eventDate + "</span>";
        if (eventType === 1) {
          alertText = '<span class="red">' + alertText + '</span>';
        }
        return alertText;
      }
    };
  });

  services.factory('alert', function($resource) {
    return $resource(baseUrl + '/search', {
      msgType: 4,
      start: "'12 hours ago'"
    }, {
      query: {
        method: 'GET',
        params: {},
        isArray: true,
        transformResponse: function(data, header) {
          var jsonData;
          jsonData = JSON.parse(data);
          jsonData.pop();
          return jsonData;
        }
      }
    });
  });

}).call(this);
