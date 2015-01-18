'use strict'

angular.module 'multiplayerHtml5PongApp'
.controller "GameContainerController", ($scope, $http, socket, $rootScope, $timeout)->
  # Start Game
  # Send Current State
  # Update View
  
  # Keyboard
  keyboard = new THREEx.KeyboardState()
  playerNumber = 1;

  $scope.setupGame = (isLocal) ->
    $scope.PADDLE = 
      W: 40
      H: 120
      D: 30
      M: 5
    $scope.TABLE =
      W: 640
      H: 480
      R: -240
      L: 240
      T: 320
      B: -320
    $scope.BALL =
      VX: (if isLocal then 5 else -5)
      VY: 5
      R: 20
    $scope.ball = 
      X: 0
      Y: 0
    $scope.localPaddle =
      C: 0
    $scope.remotePaddle =
      C: 0
      
    playerNumber = isLocal
      
    updateGameState()
  
  updateGameState = ->
    $timeout updateGameState, 25

    # Move stuff around
    $scope.ball.X += $scope.BALL.VX
    $scope.ball.Y += $scope.BALL.VY
    if ($scope.ball.X - $scope.BALL.R - $scope.PADDLE.W < $scope.TABLE.B or $scope.ball.X + $scope.BALL.R + $scope.PADDLE.W > $scope.TABLE.T)
      $scope.BALL.VX *= -1
    if ($scope.ball.Y + $scope.BALL.R > $scope.TABLE.L or $scope.ball.Y - $scope.BALL.R < $scope.TABLE.R)
      $scope.BALL.VY *= -1

    # Paddle
    if (playerNumber == 0 and keyboard.pressed('left')) or (playerNumber == 1 and keyboard.pressed('a'))
      $scope.localPaddle.C += -1 * $scope.PADDLE.M if $scope.localPaddle.C + $scope.PADDLE.H/2 < $scope.TABLE.L
    if (playerNumber == 0 and keyboard.pressed('right')) or (playerNumber == 1 and keyboard.pressed('d'))
      $scope.localPaddle.C -= $scope.PADDLE.M if $scope.localPaddle.C - $scope.PADDLE.H/2 > $scope.TABLE.R
    
    socket.emit('message', playerNumber, $scope.localPaddle.C);
  
  #Hook up to the SocketIO code
  $rootScope.$on 'socket:broadcast', (event, data) ->
    console.log('received broadcast', event.name, data)
    if(data.source != playerNumber)
      $scope.remotePaddle.C = data.payload;
  
.directive "gameContainer", ->
  restrict: "E"
  template: "<div class=\"container-fluid\" id=\"container\"></div>"
  link: ($scope) ->
    class Game
      constructor: ->
  
        @width = $scope.TABLE.W
        @height = $scope.TABLE.H
  
        # Create renderer
        @renderer = new THREE.WebGLRenderer
        @renderer.setSize @width, @height
        @renderer.shadowMapEnabled = true
        console.log "Renderer size = ", @width, @height
        document.getElementById("container").appendChild @renderer.domElement
  
        # Create scene
        @scene = new THREE.Scene()
  
        # Create camera
        @camera = new THREE.PerspectiveCamera(45, @width / @height, 1, 100000)
        @camera.position.z = 1000
        @scene.add @camera
  
        # Add a light
        @light = new THREE.PointLight(0xFFFFFF)
        @light.position.x = -1000
        @light.position.z = 1000
        @light.distance = 10000
        @light.intensity = 1.2
        @scene.add @light
  
        # Add a spot light
        @spotlight = new THREE.SpotLight(0xF8D898)
        @spotlight.position.set(0, 0, 660)
        @spotlight.intensity = 1.5
        @spotlight.castShadow = true
        @scene.add @spotlight
  
        # Add a plane
        @plane = new THREE.Mesh(
          new THREE.PlaneBufferGeometry(@width, @height, 16, 16)
          new THREE.MeshLambertMaterial({ color: 0x00CC00 })
        )
        @plane.receiveShadow = true
        @scene.add @plane
  
        # Add a table
        @table = new THREE.Mesh(
          new THREE.BoxGeometry(@width+5, @height+5, 100, 16, 16)
          new THREE.MeshLambertMaterial({ color: 0x0011CC })
        )
        @table.position.z = -51
        @table.receiveShadow = true
        @scene.add @table
  
        # Add a ball
        radius = $scope.BALL.R
        @ball = new THREE.Mesh(
          new THREE.SphereGeometry(radius, 16, 16)
          new THREE.MeshLambertMaterial({ color: 0xCC0000 })
        )
        @scene.add(@ball)
        @ball.position.x = $scope.ball.X
        @ball.position.y = $scope.ball.Y
        @ball.position.z = radius
        @ball.radius = radius
        @ball.castShadow = true
        @ball.receiveShadow = true
        @vX = 3
        @vY = 3
  
        @paddleW = $scope.PADDLE.W
        @paddleH = $scope.PADDLE.H
        @paddleD = $scope.PADDLE.D
        # Add player paddle
        @paddle1 = new THREE.Mesh(
          new THREE.BoxGeometry(@paddleW, @paddleH, @paddleD, 1, 1)
          new THREE.MeshLambertMaterial({ color: 0xFFFFFF })
        )
        @paddle1.position.y = $scope.localPaddle.C
        @paddle1.position.x = -@width/2 + @paddleW/2 + 5
        @paddle1.position.z = @paddleD/2
        @paddle1.castShadow = true
        @paddle1.receiveShadow = true
        @scene.add @paddle1
        # Add player paddle
        @paddle2 = new THREE.Mesh(
          new THREE.BoxGeometry(@paddleW, @paddleH, @paddleD, 1, 1)
          new THREE.MeshLambertMaterial({ color: 0xFFFFFF })
        )
        @paddle2.position.y = $scope.remotePaddle.C
        @paddle2.position.x = +@width/2 - @paddleW/2 + 5
        @paddle2.position.z = @paddleD/2
        @paddle2.castShadow = true
        @paddle2.receiveShadow = true
        @scene.add @paddle2
  
        # Add ground
        @ground = new THREE.Mesh(
          new THREE.BoxGeometry(1000, 1000, 3, 1, 1, 1)
          new THREE.MeshLambertMaterial({ color: 0x888888 })
        )
        @ground.position.z = -100
        @ground.receiveShadow = true
        @scene.add @ground
  
        # Set the boundaries
        @left = -@width/2
        @right = @width/2
        @top = -@height/2
        @bottom = @height/2
  
        # Keyboard
        @keyboard = new THREEx.KeyboardState()
  
      draw: =>
        requestAnimationFrame @draw
  
        # Move stuff around
        @ball.position.x = $scope.ball.X
        @ball.position.y = $scope.ball.Y

        # Paddle
        @paddle1.position.y = $scope.localPaddle.C
        @paddle2.position.y = $scope.remotePaddle.C

        # Update Light / Camera
        @spotlight.position.x = @ball.position.x * 2
        @spotlight.position.y = @ball.position.y * 2
        @camera.position.x = -@width/2-600
        @camera.position.y = 0
        @camera.position.z = 600
        # @camera.rotation.x = -0.01 * (@ball.position.y) * Math.PI/180
        @camera.rotation.x = 0
        @camera.rotation.y = -60 * Math.PI/180
        @camera.rotation.z = -90 * Math.PI/180
  
        @renderer.render @scene, @camera

    game = new Game();
    game.draw();

