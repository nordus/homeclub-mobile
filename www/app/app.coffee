
angular.module("hcMobile", [
  "ionic"
  'ngResource'
  'shared'
  "hcMobile.controllers"
  "hcMobile.services"

]).config([
  '$stateProvider'
  '$urlRouterProvider'
  'BASE_URL'
  '$httpProvider'
  ($stateProvider, $urlRouterProvider, BASE_URL, $httpProvider) ->

    $httpProvider.interceptors.push 'AuthInterceptor'

    $stateProvider
      .state 'app',
        cache: false
        resolve:
          currentUser : ( SessionFactory ) ->
            SessionFactory.getSession()
        controller: ( $scope, currentUser ) ->
          $scope.currentUser = currentUser
        url: '/app'
        templateUrl: 'app/layout/menu-layout.html'
        abstract: true

      .state 'app.dash',
        url: '/dash'
        templateUrl: 'templates/dashboard.html'
        controller: 'DashCtrl'

      .state 'app.sensorSetup',
        url: '/sensor-setup'
        templateUrl: 'templates/sensor-setup.html'
        controller: 'SensorSetupCtrl'

      .state 'login',
        url: '/login'
        templateUrl: 'templates/login.html'
        controller: 'SignInCtrl'

    $urlRouterProvider.otherwise ->
      if window.localStorage.getItem 'auth-token'
        return '/app/dash'
      else
        return '/login'

]).run(($ionicPlatform, $rootScope, $ionicLoading, $timeout, $state, SessionFactory, AuthTokenFactory) ->
  $ionicPlatform.ready ->

    if window.cordova
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
    AuthTokenFactory.setToken null
    $state.go 'login'

).filter 'capitalize', ->
  ( input ) ->
    unless input is null
      input.substring( 0, 1 ).toUpperCase() + input.substring( 1 )
