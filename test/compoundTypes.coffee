typeSystem = require '../public/typeSystem'

describe 'recognizer', ->

  describe 'compound types, ASTs', ->
    it 'should recognize an object with one Integer field', ->
      system = typeSystem.init()

      type = newtype:
        name: 'IntegerField'
        fields:
          aField: 'Integer'

      err = system.register type

      system.generateParsers()
      recognize = system.getRecognizer()

      recognized = recognize('IntegerField', {aField: 1})

      recognized.should.match
        matched: true
        data: {aField: 1}
        typedata:
          type: 'IntegerField'
          iscontainer: true
          fields:
            aField:
              type: 'Integer'
              iscontainer: false

      recognize('IntegerField', {aField: 1.5}).matched.should.eql false
      recognize('IntegerField', {foo: 1}).matched.should.eql false

    it 'should recognize an object with multiple fields', ->
      system = typeSystem.init()

      type = newtype:
        name: 'ThreeFields'
        fields:
          intField: 'Integer'
          stringField: 'String'
          objectField: 'Object'

      system.register type

      system.generateParsers()
      recognize = system.getRecognizer()

      recognized = recognize('ThreeFields', {intField: 1, stringField: '1', objectField: {foo: 2}})

      recognized.should.match
        matched: true
        data: {intField: 1, stringField: '1', objectField: {foo: 2}}
        typedata:
          type: 'ThreeFields'
          iscontainer: true
          fields:
            intField:
              type: 'Integer'
              iscontainer: false
            stringField:
              type: 'String'
              iscontainer: false
            objectField:
              type: 'Object'
              iscontainer: true

      recognize('ThreeFields', {intField: 0, stringField: '', objectField: {}}).matched.should.eql true
      recognize('ThreeFields', {intField: '1', stringField: '1', objectField: {foo: 2}}).matched.should.eql false
      recognize('ThreeFields', {stringField: '1', objectField: {foo: 2}}).matched.should.eql false

    it 'should recognize an object with another object as a field', ->
      system = typeSystem.init()

      outerType = newtype:
        name: 'Outer'
        fields:
          innerField: 'Inner'

      innerType = newtype:
        name: 'Inner'
        fields:
          intField: 'Integer'

      system.register outerType
      system.register innerType

      system.generateParsers()
      recognize = system.getRecognizer()

      recognized = recognize('Outer', {innerField: {intField: 0} })

      recognized.should.match
        matched: true
        data: {innerField: {intField: 0} }
        typedata:
          type: 'Outer'
          iscontainer: true
          fields:
            innerField:
              type: 'Inner'
              iscontainer: true
              fields:
                intField:
                  type: 'Integer'
                  iscontainer: false

      recognize('Outer', {innerField: {intField: 1} }).matched.should.eql true
      recognize('Inner', {intField: 1}).matched.should.eql true
      recognize('Outer', {innerField: {notIntegerField: 1} }).matched.should.eql false
      recognize('Outer', {innerField: {intField: 'foo'} }).matched.should.eql false
