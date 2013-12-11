typeSystem = require '../src/typeSystem'
match = require '../src/match'

describe 'match', ->

  it 'should handle a type with one int field', ->
    system = typeSystem.init()

    type = newtype:
      name: 'BasicType'
      fields: [
        aNumber: 'Int'
      ]

    system.register type
    typeData = system.getDataForType type.name

    match({aNumber: 1}, typeData).should.be.true
