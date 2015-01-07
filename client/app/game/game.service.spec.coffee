'use strict'

describe 'Service: game', ->

  # load the service's module
  beforeEach module 'multiplayerHtml5PongApp'

  # instantiate service
  game = undefined
  beforeEach inject (_game_) ->
    game = _game_

  it 'should do something', ->
    expect(!!game).toBe true