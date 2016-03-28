services = angular.module 'hcMobile.services', []

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
}


services.factory 'user', ($resource, BASE_URL) ->

  $resource BASE_URL+'/users/:id', id:'@_id',
    update:
      method: 'PUT'


services.factory 'fieldhistogram', ($resource, $rootScope, $window, BASE_URL) ->

  defaultParams =
    fields                : ['sensorHubData1', 'sensorHubData2', 'sensorHubData3']
    start                 : '1 day ago'
    msgType               : 5

  $resource BASE_URL+'/fieldhistograms', defaultParams


services.factory('SessionFactory', ($window, $ionicPlatform, $timeout) ->
  _sessionFactory = {}

  _sessionFactory.createSession = (user) ->
    $window.localStorage.user = JSON.stringify(user)

  _sessionFactory.getSession = ->
    JSON.parse($window.localStorage.user)

  _sessionFactory.deleteSession = ->
    delete $window.localStorage.user
    true

  _sessionFactory.checkSession = ->
    return true if $window.localStorage.user
    false

  _sessionFactory.setRoomNames = (sensorHubs = []) ->
    currentUser = JSON.parse($window.localStorage.user)
    currentUser.roomNamesBySensorHubMacAddress = {}
    sensorHubs.forEach (sensorHub) ->
      @[sensorHub._id] = meta.sensorHubTypes[String(sensorHub.sensorHubType)]
    , currentUser.roomNamesBySensorHubMacAddress
    $window.localStorage.user = JSON.stringify currentUser

  _sessionFactory
)


services.factory('AuthFactory', ($http, BASE_URL) ->
  _authFactory = {}

  _authFactory.login = (user) ->
    $http.post BASE_URL+'/login', user

  _authFactory
)


services.factory('latest', ($resource, BASE_URL) ->

  $resource BASE_URL+'/latest/sensor-hub-events'

)


services.factory('sensorhub', ($resource, BASE_URL) ->

  $resource BASE_URL+'/sensor-hubs/:id',
    id: '@_id'
  ,
    update: { method:'PUT' }

).factory('customeraccount', ($resource, BASE_URL) ->
  $resource BASE_URL+'/customer-accounts/:id',
    id: '@_id'
  ,
    update: { method:'PUT' }
)


services.factory('meta', ->
  meta
)

services.factory 'alerttext', ( $filter ) ->

  sensorHubEvent: (message) ->
    eventDate = $filter('date')(message.updateTime, 'MMM d h:mm a', 'UTC')
    eventResolved = message.sensorEventEnd isnt 0
    if eventResolved
      eventType = message.sensorEventEnd
    else
      eventType = message.sensorEventStart
    alertText = switch eventType
      when 1 then '<i class="icon ion-waterdrop"></i> Water detect'
      when 2 then '<i class="icon ion-eye"></i> Motion detect'
      when 3 then '<i class="icon ion-thermometer"></i> Low temperature'
      when 4 then '<i class="icon ion-thermometer"></i> High temperature'
      when 5 then '<i class="icon ion-ios-rainy"></i> Low humidity'
      when 6 then '<i class="icon ion-ios-rainy"></i> High humidity'
      when 7 then '<i class="icon ion-lightbulb"></i> Low light'
      when 8 then '<i class="icon ion-lightbulb"></i> High light'
      when 9 then '<i class="icon ion-reply-all"></i> Movement'
    if eventResolved
      alertText += ' resolved'
    alertText += " <span class='small-text'>#{eventDate}</span>"
    # water alert text should be red
    if eventType is 1
      alertText = '<span class="red">' + alertText + '</span>'
    alertText

services.factory 'alert', ( $resource, BASE_URL ) ->
  $resource BASE_URL+'/search',
    msgType : 4
    start   : "'12 hours ago'"
  ,
    query:
      method: 'GET'
      params: {}
      isArray: true
      transformResponse: ( data, header ) ->
        jsonData = JSON.parse( data )
        # remove first alert from array as it is already displayed as 'latestAlert'
        jsonData.pop()
        return jsonData


services.factory 'AuthTokenFactory', ( $window ) ->
  store = $window.localStorage
  key   = 'auth-token'

  getToken  : ->
    store.getItem( key )

  setToken  : ( token ) ->
    if token
      store.setItem( key, token )
    else
      store.removeItem( key )


services.factory 'AuthInterceptor', ( AuthTokenFactory ) ->
  request  : ( config ) ->
    token = AuthTokenFactory.getToken()

    if token
      config.headers  = config.headers || {}
      config.headers.Authorization  = "Bearer #{token}"

    return config
