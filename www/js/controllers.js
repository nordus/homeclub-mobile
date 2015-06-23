// Generated by CoffeeScript 1.8.0
(function() {
  var app, baseUrl,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  app = angular.module("hcMobile.controllers", ['ngSanitize']);

  baseUrl = 'http://homeclub.us/api';

  app.controller('DashCtrl', function($scope, alert, alerttext, latest, SessionFactory) {
    $scope.alerttext = alerttext;
    $scope.currentUser = SessionFactory.getSession();
    $scope.refreshLatest = function() {
      $scope.loading = true;
      return latest.get({
        sensorHubMacAddresses: $scope.currentUser.gateways[0].sensorHubs,
        start: "'12 hours ago'"
      }, function(data) {
        $scope.loading = false;
        return $scope.latest = data;
      });
    };
    $scope.refreshLatest();
    $scope.alerts = {};
    $scope.toggleAlerts = function(sensorHubMacAddress) {
      if ($scope.alerts[sensorHubMacAddress]) {
        return $scope.alerts[sensorHubMacAddress] = void 0;
      } else {
        return alert.query({
          sensorHubMacAddress: sensorHubMacAddress
        }, function(alerts) {
          return $scope.alerts[sensorHubMacAddress] = alerts;
        });
      }
    };
    $scope.hasAlert = function(sensorHubMacAddress) {
      return $scope.latest[sensorHubMacAddress].latestAlert !== void 0;
    };
    $scope.noAlert = function(sensorHubMacAddress) {
      return $scope.latest[sensorHubMacAddress].latestAlert === void 0;
    };
    return $scope.showOkIfNoAlerts = function(roomName) {
      return roomName === 'Water Detect' || roomName === 'Human Motion' || roomName === 'Item Movement';
    };
  });

  app.controller('SensorSetupCtrl', function($scope, customeraccount, meta, sensorhub, SessionFactory, $rootScope, resolvedCustomerAccount) {
    var sensorTypesBySensorHubTypeId;
    $scope.currentUser = SessionFactory.getSession();
    $scope.customerAccount = new customeraccount(resolvedCustomerAccount.data);
    $scope.meta = meta;
    sensorhub.query({
      sensorHubMacAddresses: $scope.currentUser.gateways[0].sensorHubs
    }, function(sensorHubs) {
      return $scope.sensorHubs = sensorHubs;
    });
    $scope.sensorTypes = ['humidity', 'light', 'motion', 'movement', 'temperature', 'water'];
    sensorTypesBySensorHubTypeId = {
      '1': ['temperature'],
      '2': ['humidity', 'light', 'temperature'],
      '3': ['movement'],
      '4': ['motion']
    };
    $scope.sensorTypesOfCurrentSensorHub = function(sensorHub) {
      return sensorTypesBySensorHubTypeId[sensorHub.sensorHubType] || [];
    };
    $scope.toggleSubscription = function(sensorHub, deliveryMethod, sensorType) {
      var subscriptions;
      subscriptions = sensorHub["" + deliveryMethod + "Subscriptions"];
      if (__indexOf.call(subscriptions, sensorType) >= 0) {
        return subscriptions.splice(subscriptions.indexOf(sensorType), 1);
      } else {
        return subscriptions.push(sensorType);
      }
    };
    $scope.isChecked = function(sensorHub, value, deliveryMethod) {
      var checkedNotifications, indexOfValue, notificationName;
      notificationName = "" + deliveryMethod + "Subscriptions";
      checkedNotifications = sensorHub[notificationName];
      indexOfValue = checkedNotifications.indexOf(value);
      return indexOfValue !== -1;
    };
    return $scope.save = function() {
      $scope.sensorHubs.forEach(function(sensorHub) {
        return sensorHub.$update();
      });
      SessionFactory.setRoomNames($scope.sensorHubs);
      return $scope.customerAccount.$update(function(customerAccount) {
        return $rootScope.toast('Saved');
      });
    };
  });

  app.controller('SignInCtrl', function($scope, $state, $http, $rootScope, AuthFactory, SessionFactory, sensorhub, meta) {
    $scope.login = function(user) {
      $rootScope.showLoading("Authenticating..");
      return AuthFactory.login(user).success(function(data) {
        localStorage.userCredentials = JSON.stringify(user);
        return $http.get(baseUrl + '/me/customer-account').success(function(currentUser) {
          SessionFactory.createSession(currentUser);
          return sensorhub.query({
            sensorHubMacAddresses: currentUser.gateways[0].sensorHubs
          }, function(sensorHubs) {
            SessionFactory.setRoomNames(sensorHubs);
            $state.go('app.dash');
            return $rootScope.hideLoading();
          });
        });
      }).error(function(data) {
        $rootScope.hideLoading();
        return $rootScope.toast('Invalid Credentials');
      });
    };
    if (!localStorage.user && localStorage.userCredentials) {
      return $scope.login(JSON.parse(localStorage.userCredentials));
    }
  });

}).call(this);
