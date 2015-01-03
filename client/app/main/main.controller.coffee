'use strict'

angular.module 'multiplayerHtml5PongApp'
.controller 'MainCtrl', ($scope, $http, socket, $rootScope) ->
  $scope.awesomeThings = []

  $http.get('/api/things').success (awesomeThings) ->
    $scope.awesomeThings = awesomeThings

  console.log "Emitting message"
  socket.emit('message', 'terry', 'this is a test!')

  $rootScope.$on 'socket:broadcast', (event, data) ->
      console.log('received broadcast', event.name, data)


