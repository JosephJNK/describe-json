typeSystem = require '../src/typeSystem'
should = require 'should'

describe 'typeSystem', ->

  describe 'register', ->

    it 'should register the name of a type', ->
      type = newtype: name: 'Type'

      error = typeSystem.register type
      should.not.exist error

      typeSystem.types().should.includeEql type.newtype.name
