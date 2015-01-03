'use strict'

angular.module 'multiplayerHtml5PongApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'ui.bootstrap'
  'btford.socket-io'
]
.config ($routeProvider, $locationProvider) ->
  $routeProvider
  .when '/game',
    templateUrl: "/app/game/game.html"
    controller: "GameCtrl"
  .otherwise
    redirectTo: '/'

  $locationProvider.html5Mode true
