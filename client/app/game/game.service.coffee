'use strict'

angular.module 'multiplayerHtml5PongApp'
.factory 'Game', ->
  class Game
    constructor: ->

      @width = 640
      @height = 480

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
      radius = 20
      @ball = new THREE.Mesh(
        new THREE.SphereGeometry(radius, 16, 16)
        new THREE.MeshLambertMaterial({ color: 0xCC0000 })
      )
      @scene.add(@ball)
      @ball.position.x = 0
      @ball.position.y = 0
      @ball.position.z = radius
      @ball.radius = radius
      @ball.castShadow = true
      @ball.receiveShadow = true
      @vX = 3
      @vY = 3

      @paddleW = 40
      @paddleH = 120
      @paddleD = 30
      # Add player paddle
      @paddle1 = new THREE.Mesh(
        new THREE.BoxGeometry(@paddleW, @paddleH, @paddleD, 1, 1)
        new THREE.MeshLambertMaterial({ color: 0xFFFFFF })
      )
      @paddle1.position.x = -@width/2 + @paddleW/2 + 5
      @paddle1.position.z = @paddleD/2
      @paddle1.castShadow = true
      @paddle1.receiveShadow = true
      @scene.add @paddle1

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
      @ball.position.x += @vX
      @ball.position.y += @vY
      if (@ball.position.x - @ball.radius - @paddleW < @left or @ball.position.x + @ball.radius > @right)
        @vX *= -1
      if (@ball.position.y - @ball.radius < @top or @ball.position.y + @ball.radius > @bottom)
        @vY *= -1

      # Paddle
      if @keyboard.pressed('left')
        @paddle1.position.y += 5 if @paddle1.position.y + @paddleH/2 < @height/2
      if @keyboard.pressed('right')
        @paddle1.position.y -= 5 if @paddle1.position.y - @paddleH/2 > -@height/2

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


