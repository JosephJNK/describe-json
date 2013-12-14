recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  describe 'compound types', ->

    it 'should recognize an object with one Int field', ->
      system = typeSystem.init()

      type = newtype:
        name: 'IntField'
        fields: [
          aField: 'Int'
        ]

      system.register type

      recognize = recognizer.init system

      recognize('IntField', {aField: 1}).should.be true
      recognize('IntField', {aField: 1.5}).should.be false
      recognize('IntField', {foo: 1}).should.be false
