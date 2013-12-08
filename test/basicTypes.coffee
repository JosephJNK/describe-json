typeSystem = require '../src/typeSystem'
should = require 'should'

describe 'register', ->
  
  describe 'basic types', ->

    it 'should let you register a type with Int fields', ->
      system = typeSystem.init()

      type = newtype:
        name: 'BasicType'
        fields: [
          aField: 'Int'
        ]

      error = system.register type
      should.not.exist error
