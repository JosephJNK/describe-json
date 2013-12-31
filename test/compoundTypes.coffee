recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  describe 'compound types, ASTs', ->
    it 'should recognize an object with one Int field', ->
      system = typeSystem.init()

      type = newtype:
        name: 'IntField'
        fields: [
          aField: 'Int'
        ]

      system.register type

      recognize = recognizer.init system

      recognize('IntField', {aField: 1}).matched.should.eql true
      recognize('IntField', {aField: 1.5}).matched.should.eql false
      recognize('IntField', {foo: 1}).matched.should.eql false


    it 'should recognize an object with multiple fields', ->
      system = typeSystem.init()

      type = newtype:
        name: 'ThreeFields'
        fields: [
          {intField: 'Int'}
          {stringField: 'String'}
          {objectField: 'Object'}
        ]

      system.register type

      recognize = recognizer.init system

      recognize('ThreeFields', {intField: 0, stringField: '', objectField: {}}).matched.should.eql true
      recognize('ThreeFields', {intField: 1, stringField: '1', objectField: {foo: 2}}).matched.should.eql true
      recognize('ThreeFields', {intField: '1', stringField: '1', objectField: {foo: 2}}).matched.should.eql false
      recognize('ThreeFields', {stringField: '1', objectField: {foo: 2}}).matched.should.eql false

    it 'should recognize an object with another object as a field', ->
      system = typeSystem.init()

      outerType = newtype:
        name: 'Outer'
        fields: [
          innerField: 'Inner'
        ]

      innerType = newtype:
        name: 'Inner'
        fields: [
          intField: 'Int'
        ]

      system.register outerType
      system.register innerType

      recognize = recognizer.init system

      recognize('Outer', {innerField: {intField: 1} }).matched.should.eql true
      recognize('Outer', {innerField: {intField: 0} }).matched.should.eql true
      recognize('Inner', {intField: 1}).matched.should.eql true
      recognize('Outer', {innerField: {notIntField: 1} }).matched.should.eql false
      recognize('Outer', {innerField: {intField: 'foo'} }).matched.should.eql false
