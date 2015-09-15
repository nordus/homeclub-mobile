
if window.cordova or location.hostname is 'localhost'
  baseUrl = 'http://homeclub.us/api'
else
  baseUrl = '/api'


app = angular.module( 'shared', [] )


app.constant 'BASE_URL', baseUrl
