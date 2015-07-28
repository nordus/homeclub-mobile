
app     = angular.module "hcMobile.controllers", ['ngSanitize', 'ngCordova']
baseUrl = 'http://homeclub.us/api'


app.controller 'DashCtrl', ($scope, alert, alerttext, latest, SessionFactory) ->

  ga 'send', 'screenview', screenName:'/dashboard'

  $scope.alerttext = alerttext

  $scope.currentUser = SessionFactory.getSession()

  $scope.refreshLatest = ->

    $scope.loading = true

    latest.get {sensorHubMacAddresses:$scope.currentUser.gateways[0].sensorHubs, start:"'12 hours ago'"}, (data) ->
      $scope.loading = false
      $scope.$broadcast 'scroll.refreshComplete'
      $scope.latest = data

  $scope.refreshLatest()

  $scope.alerts = {}

  $scope.toggleAlerts = ( sensorHubMacAddress ) ->
    if $scope.alerts[sensorHubMacAddress]
      $scope.alerts[sensorHubMacAddress] = undefined
    else
      alert.query sensorHubMacAddress:sensorHubMacAddress, ( alerts ) ->
        $scope.alerts[sensorHubMacAddress] = alerts

  $scope.hasAlert = ( sensorHubMacAddress ) -> $scope.latest[sensorHubMacAddress].latestAlert != undefined
  $scope.noAlert  = ( sensorHubMacAddress ) -> $scope.latest[sensorHubMacAddress].latestAlert == undefined
  $scope.showOkIfNoAlerts = ( roomName ) ->
    roomName == 'Water Detect' || roomName == 'Human Motion' || roomName == 'Item Movement'


app.controller 'SensorSetupCtrl', ($scope, customeraccount, meta, sensorhub, SessionFactory, $rootScope, resolvedCustomerAccount) ->

  ga 'send', 'screenview', screenName:'/sensors'

  $scope.currentUser = SessionFactory.getSession()
  $scope.customerAccount = new customeraccount(resolvedCustomerAccount.data)
  $scope.meta = meta

  sensorhub.query(sensorHubMacAddresses:$scope.currentUser.gateways[0].sensorHubs, (sensorHubs) ->
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

    $scope.customerAccount.$update (customerAccount) ->
      $rootScope.toast 'Saved'


app.controller 'SignInCtrl', ($scope, $state, $http, $rootScope, AuthFactory, SessionFactory, sensorhub, meta, $cordovaAppVersion, $cordovaDevice) ->
  $scope.login = (user) ->
    $rootScope.showLoading "Authenticating.."
    AuthFactory
      .login(user)
      .success((data) ->

        $http.get(baseUrl+'/me/customer-account').success((currentUser) ->

          ionic.Platform.ready ->

            $cordovaAppVersion.getAppVersion().then ( version ) ->

              currentUser.uuid = $cordovaDevice.getUUID()

              ga 'create', 'UA-50394594-4',
                storage           : 'none'
                clientId          : currentUser.uuid
                userId            : currentUser._id

              ga 'set',
                appName           : 'HomeClub Mobile'
                appVersion        : version
                checkProtocolTask : null
                checkStorageTask  : null
                dimension1        : currentUser._id
                dimension2        : currentUser.carrier

              SessionFactory.createSession(currentUser)

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