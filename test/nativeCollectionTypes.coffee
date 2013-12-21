recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  describe 'encountering native collections', ->

    it 'should recognize an Array', ->
      recognize = recognizer.init typeSystem.init()
      parsed = recognize('Array', [])

      parsed.should.eql
        matched: true
        data: []
        typedata:
          iscontainer: true
          type: 'Array'

      parsed2 = recognize('Array', [1])

      parsed2.should.eql
        matched: true
        data: [1]
        typedata:
          iscontainer: true
          type: 'Array'
          fields: [
            {
              type: 'Int'
              iscontainer: false
            }
          ]

      parsed3 = recognize('Array', [null])

      parsed3.should.eql
        matched: true
        data: [null]
        typedata:
          iscontainer: true
          type: 'Array'
          fields: [
            {
              type: 'Null'
              iscontainer: false
            }
          ]

      parsed4 = recognize('Array', [undefined])

      parsed4.should.eql
        matched: true
        data: [undefined]
        typedata:
          iscontainer: true
          type: 'Array'
          fields: [
            {
              type: 'Undefined'
              iscontainer: false
            }
          ]

      recognize('Array', 3).matched.should.eql false
      recognize('Array', 3.1).matched.should.eql false
      recognize('Array', '3.1').matched.should.eql false
      recognize('Array', NaN).matched.should.eql false
      recognize('Array', {3.1}).matched.should.eql false
      recognize('Array', null).matched.should.eql false
      recognize('Array', undefined).matched.should.eql false
      recognize('Array', {}).matched.should.eql false

    it 'should recognize an Object', ->
      recognize = recognizer.init typeSystem.init()
      parsed = recognize('Object', {})

      parsed.should.eql
        matched: true
        data: {}
        typedata:
          iscontainer: true
          type: 'Object'
          fields: {}

      parsed2 = recognize('Object', {foo: 1})

      parsed2.should.eql
        matched: true
        data: {foo: 1}
        typedata:
          iscontainer: true
          type: 'Object'
          fields:
            foo:
              type: 'Int'
              iscontainer: false

      parsed3 = recognize('Object', {foo: null})

      parsed3.should.eql
        matched: true
        data: {foo: null}
        typedata:
          iscontainer: true
          type: 'Object'
          fields:
            foo:
              type: 'Null'
              iscontainer: false

      parsed4 = recognize('Object', {foo: undefined})

      parsed4.should.eql
        matched: true
        data: {foo: undefined}
        typedata:
          iscontainer: true
          type: 'Object'
          fields:
            foo:
              type: 'Undefined'
              iscontainer: false

      recognize('Object', 3).matched.should.eql false
      recognize('Object', 3.1).matched.should.eql false
      recognize('Object', '3.1').matched.should.eql false
      recognize('Object', NaN).matched.should.eql false
      recognize('Object', null).matched.should.eql false
      recognize('Object', undefined).matched.should.eql false
      recognize('Object', []).matched.should.eql false
