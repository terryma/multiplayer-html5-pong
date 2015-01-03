(function() {

  'use strict';
  angular.module('multiplayerHtml5PongApp').controller('GameCtrl', function($scope, $http) {
    $scope.awesomeThings = [];
    return $http.get('/api/things').success(function(awesomeThings) {
      return $scope.awesomeThings = awesomeThings.concat({name:"TEST!"});
    });
  });

}).call(this);

