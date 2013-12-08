typeSystem = require '../src/typeSystem'
dispatcher = require '../src/dispatcher'

describe 'dispatch', ->

  it 'should match otherwise when its the only array element', (done) ->
    system = typeSystem.init()
    dispatch = dispatcher.init system

    dispatch {}, [otherwise: -> done()]
