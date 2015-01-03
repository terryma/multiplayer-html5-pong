'use strict'

describe 'Service: socket', ->

  # load the service's module
  beforeEach module 'multiplayerHtml5PongApp'

  # instantiate service
  socket = undefined
  beforeEach inject (_socket_) ->
    socket = _socket_

  it 'should do something', ->
    expect(!!socket).toBe true