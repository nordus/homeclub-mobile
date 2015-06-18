services = angular.module 'hcMobile.services', []
baseUrl = 'http://homeclub.us/api'
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

services.factory('SessionFactory', ($window) ->
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


services.factory('AuthFactory', ($http) ->
  _authFactory = {}

  _authFactory.login = (user) ->
    $http.post baseUrl+'/login', user

  _authFactory
)


services.factory('latest', ($resource) ->

  $resource baseUrl+'/latest/sensor-hub-events'

)


services.factory('sensorhub', ($resource) ->

  $resource baseUrl+'/sensor-hubs/:id',
    id: '@_id'
  ,
    update: { method:'PUT' }

).factory('customeraccount', ($resource) ->
  $resource baseUrl+'/customer-accounts/:id',
    id: '@_id'
  ,
    update: { method:'PUT' }
)


services.factory('meta', ->
  meta
)