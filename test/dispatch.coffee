typeSystem = require '../public/typeSystem'
dispatcher = require '../public/dispatcher'

describe 'dispatch', ->

  it 'should match otherwise when its the only array element', (done) ->
    system = typeSystem.init()
    dispatch = dispatcher.init system

    dispatch {}, [otherwise: -> done()]

  describe.skip 'waiting for match to work', ->
    it 'should match a basic type with an Int field', (done) ->
      system = typeSystem.init()

      type = newtype:
        name: 'BasicType'
        fields: [
          aNumber: 'Int'
        ]

      system.register type
      dispatch = dispatcher.init system

      succeedOn1 = ({aNumber}) -> if aNumber is 1 then done() else throw "fail"

      dispatch {aNumber: 1}, [BasicType: succeedOn1]
