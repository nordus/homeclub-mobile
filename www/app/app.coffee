
if window.cordova or location.hostname is 'localhost'
  baseUrl = 'http://homeclub.us/api'
else
  baseUrl = '/api'


angular.module("hcMobile", [
  "ionic"
  'ngResource'
  'ionic.service.core'
#  'ionic.service.push'
#  'ionic.service.deploy'
  "hcMobile.controllers"
  "hcMobile.services"
]).config(['$stateProvider', '$urlRouterProvider', '$ionicAppProvider', ($stateProvider, $urlRouterProvider, $ionicAppProvider) ->

  $ionicAppProvider.identify
    app_id: '627f4314'
    api_key: '08802936b07eeb891a3cad5efc08cb59252541816f75aa8d'

  $stateProvider
    .state('app',
      url: '/app'
      templateUrl: 'app/layout/menu-layout.html'
      abstract: true
    ).state('app.dash',
      url: '/dash'
      views:
        mainContent:
          templateUrl: 'templates/dashboard.html'
          controller: 'DashCtrl'
    ).state('app.sensorSetup',
      resolve:
        resolvedCustomerAccount: ($http) ->
          $http.get baseUrl+'/me/customer-account'
      url: '/sensor-setup'
      views:
        mainContent:
          templateUrl: 'templates/sensor-setup.html'
          controller: 'SensorSetupCtrl'
    ).state('login',
      url: '/login'
      views:
        '':
          templateUrl: 'templates/login.html'
          controller: 'SignInCtrl'
    )

  $urlRouterProvider.otherwise '/login'

]).run(($ionicPlatform, $rootScope, $ionicLoading, $timeout, $state, SessionFactory) ->
  $ionicPlatform.ready ->

    pushNotification = window.plugins.pushNotification

    # register with APN/GCM, then send token to alerts server
    if ionic.Platform.isAndroid()
      token = localStorage.getItem 'Android_token'
      unless token
        pushNotification.register pushCallbacks.GCM.successfulRegistration, pushCallbacks.errorHandler,
          senderID  : '125902103424'
          ecb       : 'pushCallbacks.GCM.onNotification'

    if ionic.Platform.isIOS()
      token = localStorage.getItem 'iPhone_token'
      unless token
        pushNotification.register pushCallbacks.APN.successfulRegistration, pushCallbacks.errorHandler,
          badge : 'true'
          sound : 'true'
          alert : 'true'
          ecb   : 'pushCallbacks.APN.onNotification'


    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
#    if window.cordova and window.cordova.plugins.Keyboard
#      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true

    # org.apache.cordova.statusbar required
    StatusBar.styleDefault()  if window.StatusBar

  $rootScope.showLoading = (msg) ->
    $ionicLoading.show
      template: msg or "Loading"
      animation: "fade-in"
      showBackdrop: true
      maxWidth: 200
      showDelay: 0

  $rootScope.hideLoading = ->
    $ionicLoading.hide()

  $rootScope.toast = (msg) ->
    $rootScope.showLoading msg
    $timeout (->
      $rootScope.hideLoading()
    ), 2999

  $rootScope.logout = ->
    SessionFactory.deleteSession()
    $state.go 'login'

).filter 'capitalize', ->
  ( input ) ->
    unless input is null
      input.substring( 0, 1 ).toUpperCase() + input.substring( 1 )