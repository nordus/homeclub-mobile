
app     = angular.module "hcMobile.controllers", ['ngSanitize', 'ngCordova', 'firebase']


app.controller 'AccountCtrl', ($rootScope, $scope, customeraccount, SessionFactory, user) ->
  $scope.currentUser = SessionFactory.getSession()
  gatewaysPopulated = $scope.currentUser.gateways
  $scope.customerAccount = new customeraccount($scope.currentUser)
  $scope.user = new user($scope.currentUser.user)

  $scope.save = ->
    $scope.user.$update()
    $scope.customerAccount.$update (customerAccountResp) ->
      customerAccountResp.gateways = gatewaysPopulated
      SessionFactory.createSession customerAccountResp
      $rootScope.toast 'Saved!'


app.controller 'ReportsCtrl', ($scope, fieldhistogram, $ionicSlideBoxDelegate, $timeout, $window, SessionFactory) ->

  $scope.currentUser = SessionFactory.getSession()

  $scope.searchParams =
    interval  : 'hour'
    start     : '1 day ago'
    sensorHubMacAddresses: $scope.currentUser.gateways[0].sensorHubs

  fieldhistogram.get $scope.searchParams, (data) ->
    $scope.chartData = data
    setTimeout ->
      $ionicSlideBoxDelegate.slide 0
      $ionicSlideBoxDelegate.update()
      $scope.$apply()

  angular.element( $window ).bind 'resize', ->
    $timeout ->
      $scope.$broadcast 'highchartsng.reflow'
    , 10

  Highcharts.setOptions
    global:
      useUTC: false


app.controller 'DashCtrl', ($scope, alert, alerttext, latest, currentUser, $firebaseObject) ->

  ga 'send', 'screenview', screenName:'/dashboard'

  $scope.alerttext  = alerttext

  ref               = new Firebase( 'https://homeclub-q.firebaseio.com/' + currentUser.gateways[0]._id )

  $scope.sensorHubRealtime            = $firebaseObject( ref.child( 'sensorHubs' ) )
  $scope.latestNetworkHubPowerSource  = $firebaseObject( ref.child( 'latestPowerStatus' ) )
  $scope.latestNetworkHubRssi         = $firebaseObject( ref.child( 'latestRssi' ) )

  $scope.cssClassByRssiThreshold = (rssi) ->
    return 'light' if rssi is undefined
    rssiNum = Number(rssi)
    switch
      when rssiNum < -95 then 'assertive'
      when rssiNum < -80 then 'energized'
      else 'balanced'

  $scope.hasAlert                     = ( sensorHubMacAddress ) ->
    $scope.sensorHubRealtime[sensorHubMacAddress]?.latestAlert != undefined

  $scope.noAlert                      = ( sensorHubMacAddress ) ->
    $scope.sensorHubRealtime[sensorHubMacAddress]?.latestAlert == undefined

  $scope.alerts = {}

  $scope.toggleAlerts = ( sensorHubMacAddress ) ->
    if $scope.alerts[sensorHubMacAddress]
      $scope.alerts[sensorHubMacAddress] = undefined
    else
      alert.query sensorHubMacAddress:sensorHubMacAddress, ( alerts ) ->
        $scope.alerts[sensorHubMacAddress] = alerts

  $scope.showOkIfNoAlerts = ( roomName ) ->
    roomName in ['Water Detect', 'Human Motion', 'Item Movement']


app.controller 'SensorSetupCtrl', ($scope, meta, sensorhub, SessionFactory, $rootScope, currentUser) ->

  ga 'send', 'screenview', screenName:'/sensors'

  $scope.meta = meta

  sensorhub.query(sensorHubMacAddresses:currentUser.gateways[0].sensorHubs, (sensorHubs) ->
    $scope.sensorHubs = sensorHubs
  )

  $scope.sensorTypes = ['humidity', 'light', 'motion', 'movement', 'temperature', 'water']

  sensorTypesBySensorHubTypeId =
      '1' : ['temperature']
      '2' : ['humidity', 'light', 'temperature']
      '3' : ['movement']
      '4' : ['motion']

  $scope.sensorTypesOfCurrentSensorHub = (sensorHub) ->
    sensorTypesBySensorHubTypeId[sensorHub.sensorHubType] || []

  $scope.toggleSubscription = (sensorHub, deliveryMethod, sensorType) ->
    subscriptions = sensorHub["#{deliveryMethod}Subscriptions"]
    if sensorType in subscriptions
      subscriptions.splice subscriptions.indexOf(sensorType), 1
    else
      subscriptions.push sensorType

  $scope.isChecked = (sensorHub, value, deliveryMethod) ->
    notificationName = "#{deliveryMethod}Subscriptions"
    checkedNotifications = sensorHub[notificationName]
    indexOfValue = checkedNotifications.indexOf(value)
    indexOfValue isnt -1

  $scope.save = ->
    $scope.sensorHubs.forEach (sensorHub) ->
      sensorHub.$update()

    SessionFactory.setRoomNames $scope.sensorHubs

    $rootScope.toast 'Saved'


app.controller 'SignInCtrl', ($scope, $state, $http, $rootScope, AuthFactory, SessionFactory, sensorhub, meta, $cordovaAppVersion, $cordovaDevice, BASE_URL, AuthTokenFactory) ->
  $scope.login = (user) ->
    $rootScope.showLoading "Authenticating.."
    AuthFactory
      .login(user)
      .success((data) ->

        $http.get(BASE_URL+'/me/customer-account').success(( resp ) ->

          ionic.Platform.ready ->

            currentUser       = resp.account

            currentUser.uuid  = if window.cordova then $cordovaDevice.getUUID() else currentUser._id

            ga 'create', 'UA-50394594-4',
              storage           : 'none'
              clientId          : currentUser.uuid
              userId            : currentUser._id

            analyticsParams =
              appName           : 'HomeClub Mobile'
              checkProtocolTask : null
              checkStorageTask  : null
              dimension1        : currentUser._id
              dimension2        : currentUser.carrier

            setAnalytics    = ->
              ga 'set', analyticsParams

            if window.cordova
              $cordovaAppVersion.getAppVersion().then ( version ) ->
                analyticsParams.appVersion  = version
                setAnalytics()
            else
              setAnalytics()

            SessionFactory.createSession(currentUser)

            AuthTokenFactory.setToken resp.token

            sensorhub.query(sensorHubMacAddresses:currentUser.gateways[0].sensorHubs, (sensorHubs) ->
              SessionFactory.setRoomNames sensorHubs
              $state.go 'app.dash'
              $rootScope.hideLoading()
            )
        )
      ).error((data) ->
        $rootScope.hideLoading()
        $rootScope.toast 'Invalid Credentials'
      )
