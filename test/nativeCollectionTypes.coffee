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
          type: 'Array'
          iscontainer: true
          fields: []

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
          type: 'Object'
          iscontainer: true
          fields: {}

      recognize('Object', 3).matched.should.eql false
      recognize('Object', 3.1).matched.should.eql false
      recognize('Object', '3.1').matched.should.eql false
      recognize('Object', NaN).matched.should.eql false
      recognize('Object', null).matched.should.eql false
      recognize('Object', undefined).matched.should.eql false
      recognize('Object', []).matched.should.eql false
