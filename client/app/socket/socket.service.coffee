'use strict'

angular.module 'multiplayerHtml5PongApp'
.factory 'socket', (socketFactory) ->
  socket = socketFactory()
  socket.forward('broadcast')
  socket

