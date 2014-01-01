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

      recognized = recognize('IntField', {aField: 1})

      recognized.matched.should.eql true
      recognized.data.should.eql {aField: 1}
      recognized.typedata.type.should.eql 'IntField'
      recognized.typedata.iscontainer.should.eql true
      recognized.typedata.fields.aField.type.should.eql 'Int'
      recognized.typedata.fields.aField.iscontainer.should.eql false

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

      recognized = recognize('ThreeFields', {intField: 1, stringField: '1', objectField: {foo: 2}})

      recognized.matched.should.eql true
      recognized.data.should.eql {intField: 1, stringField: '1', objectField: {foo: 2}}
      recognized.typedata.type.should.eql 'ThreeFields'
      recognized.typedata.iscontainer.should.eql true
      recognized.typedata.fields.intField.type.should.eql 'Int'
      recognized.typedata.fields.intField.iscontainer.should.eql false
      recognized.typedata.fields.stringField.type.should.eql 'String'
      recognized.typedata.fields.stringField.iscontainer.should.eql false
      recognized.typedata.fields.objectField.type.should.eql 'Object'
      recognized.typedata.fields.objectField.iscontainer.should.eql true

      recognize('ThreeFields', {intField: 0, stringField: '', objectField: {}}).matched.should.eql true
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

      recognized = recognize('Outer', {innerField: {intField: 0} })

      recognized.matched.should.eql true
      recognized.data.should.eql {innerField: {intField: 0} }
      recognized.typedata.type.should.eql 'Outer'
      recognized.typedata.iscontainer.should.eql true
      recognized.typedata.fields.innerField.type.should.eql 'Inner'
      recognized.typedata.fields.innerField.iscontainer.should.eql true
      recognized.typedata.fields.innerField.fields.intField.type.should.eql 'Int'
      recognized.typedata.fields.innerField.fields.intField.iscontainer.should.eql false

      recognize('Outer', {innerField: {intField: 1} }).matched.should.eql true
      recognize('Inner', {intField: 1}).matched.should.eql true
      recognize('Outer', {innerField: {notIntField: 1} }).matched.should.eql false
      recognize('Outer', {innerField: {intField: 'foo'} }).matched.should.eql false
