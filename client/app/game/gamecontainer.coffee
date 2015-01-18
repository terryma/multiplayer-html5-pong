'use strict'

angular.module 'multiplayerHtml5PongApp'
.controller "GameContainerController", ($scope, $http, socket, $rootScope, Game)->
  game = new Game()
  game.draw()
.directive "gameContainer", ->
  restrict: "E"
  template: "<div class=\"container-fluid\" id=\"container\"></div>"
