// Generated by CoffeeScript 1.8.0
(function() {
  var baseUrl;

  if (window.cordova || location.hostname === 'localhost') {
    baseUrl = 'http://homeclub.us/api';
  } else {
    baseUrl = '/api';
  }

  angular.module("hcMobile", ["ionic", 'ngResource', 'ionic.service.core', "hcMobile.controllers", "hcMobile.services"]).config([
    '$stateProvider', '$urlRouterProvider', '$ionicAppProvider', function($stateProvider, $urlRouterProvider, $ionicAppProvider) {
      $ionicAppProvider.identify({
        app_id: '627f4314',
        api_key: '08802936b07eeb891a3cad5efc08cb59252541816f75aa8d'
      });
      $stateProvider.state('app', {
        url: '/app',
        templateUrl: 'app/layout/menu-layout.html',
        abstract: true
      }).state('app.dash', {
        url: '/dash',
        views: {
          mainContent: {
            templateUrl: 'templates/dashboard.html',
            controller: 'DashCtrl'
          }
        }
      }).state('app.sensorSetup', {
        resolve: {
          resolvedCustomerAccount: function($http) {
            return $http.get(baseUrl + '/me/customer-account');
          }
        },
        url: '/sensor-setup',
        views: {
          mainContent: {
            templateUrl: 'templates/sensor-setup.html',
            controller: 'SensorSetupCtrl'
          }
        }
      }).state('login', {
        url: '/login',
        views: {
          '': {
            templateUrl: 'templates/login.html',
            controller: 'SignInCtrl'
          }
        }
      });
      return $urlRouterProvider.otherwise('/login');
    }
  ]).run(function($ionicPlatform, $rootScope, $ionicLoading, $timeout, $state, SessionFactory) {
    $ionicPlatform.ready(function() {
      var pushNotification, token;
      pushNotification = window.plugins.pushNotification;
      if (ionic.Platform.isAndroid()) {
        if (window.StatusBar) {
          StatusBar.backgroundColorByHexString('#6cc6c6');
        }
        token = localStorage.getItem('Android_token');
        if (!token) {
          pushNotification.register(pushCallbacks.GCM.successfulRegistration, pushCallbacks.errorHandler, {
            senderID: '125902103424',
            ecb: 'pushCallbacks.GCM.onNotification'
          });
        }
      }
      if (ionic.Platform.isIOS()) {
        token = localStorage.getItem('iPhone_token');
        if (!token) {
          pushNotification.register(pushCallbacks.APN.successfulRegistration, pushCallbacks.errorHandler, {
            badge: 'true',
            sound: 'true',
            alert: 'true',
            ecb: 'pushCallbacks.APN.onNotification'
          });
        }
      }
      if (window.cordova && window.cordova.plugins.Keyboard) {
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
      if (window.StatusBar) {
        return StatusBar.styleDefault();
      }
    });
    $rootScope.showLoading = function(msg) {
      return $ionicLoading.show({
        template: msg || "Loading",
        animation: "fade-in",
        showBackdrop: true,
        maxWidth: 200,
        showDelay: 0
      });
    };
    $rootScope.hideLoading = function() {
      return $ionicLoading.hide();
    };
    $rootScope.toast = function(msg) {
      $rootScope.showLoading(msg);
      return $timeout((function() {
        return $rootScope.hideLoading();
      }), 2999);
    };
    return $rootScope.logout = function() {
      SessionFactory.deleteSession();
      return $state.go('login');
    };
  }).filter('capitalize', function() {
    return function(input) {
      if (input !== null) {
        return input.substring(0, 1).toUpperCase() + input.substring(1);
      }
    };
  });

}).call(this);
