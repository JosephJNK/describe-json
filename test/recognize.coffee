recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  describe 'error messages', ->

    it 'should tell you when you try to access an unregistered type', ->
      recognize = recognizer.init typeSystem.init()
      try
        recognize 'Invalid', {}
      catch e
        e.should.eql "Error: 'Invalid' is not a registered type"


  describe 'basic types', ->

    it 'should recognize an Int', ->
      recognize = recognizer.init typeSystem.init()

      parsed = recognize('Int', 3)

      parsed.should.eql
        matched: true
        data: 3
        typedata:
          type: 'Int'
          iscontainer: false

      recognize('Int', 3.1).matched.should.eql false
      recognize('Int', '3').matched.should.eql false
      recognize('Int', NaN).matched.should.eql false
      recognize('Int', {3}).matched.should.eql false
      recognize('Int', [3]).matched.should.eql false
      recognize('Int', null).matched.should.eql false
      recognize('Int', undefined).matched.should.eql false
      recognize('Int', []).matched.should.eql false
      recognize('Int', {}).matched.should.eql false

    it 'should recognize a Float', ->
      recognize = recognizer.init typeSystem.init()
      parsed = recognize('Float', 3.1)

      parsed.should.eql
        matched: true
        data: 3.1
        typedata:
          type: 'Float'
          iscontainer: false

      recognize('Float', 3).matched.should.eql false
      recognize('Float', '3.1').matched.should.eql false
      recognize('Float', NaN).matched.should.eql false
      recognize('Float', {3.1}).matched.should.eql false
      recognize('Float', [3.1]).matched.should.eql false
      recognize('Float', null).matched.should.eql false
      recognize('Float', undefined).matched.should.eql false
      recognize('Float', []).matched.should.eql false
      recognize('Float', {}).matched.should.eql false

    it 'should recognize a Number', ->
      recognize = recognizer.init typeSystem.init()
      parsed = recognize('Number', 3.1)

      parsed.should.eql
        matched: true
        data: 3.1
        typedata:
          type: 'Number'
          iscontainer: false

      parsed2 = recognize('Number', 3)

      parsed2.should.eql
        matched: true
        data: 3
        typedata:
          type: 'Number'
          iscontainer: false

      recognize('Number', '3.1').matched.should.eql false
      recognize('Number', NaN).matched.should.eql false
      recognize('Number', {3.1}).matched.should.eql false
      recognize('Number', [3.1]).matched.should.eql false
      recognize('Number', null).matched.should.eql false
      recognize('Number', undefined).matched.should.eql false
      recognize('Number', []).matched.should.eql false
      recognize('Number', {}).matched.should.eql false

    it 'should recognize a String', ->
      recognize = recognizer.init typeSystem.init()
      parsed = recognize('String', '3')

      parsed.should.eql
        matched: true
        data: '3'
        typedata:
          iscontainer: false
          type: 'String'

      recognize('String', 3).matched.should.eql false
      recognize('String', 3.1).matched.should.eql false
      recognize('String', NaN).matched.should.eql false
      recognize('String', {'3.1'}).matched.should.eql false
      recognize('String', ['3', '.', '1']).matched.should.eql false
      recognize('String', null).matched.should.eql false
      recognize('String', undefined).matched.should.eql false
      recognize('String', []).matched.should.eql false
      recognize('String', {}).matched.should.eql false

    it 'should recognize a NaN', ->
      recognize = recognizer.init typeSystem.init()

      parsed = recognize('NaN', NaN)

      parsed.should.eql
        matched: true
        data: NaN
        typedata:
          iscontainer: false
          type: 'NaN'

      recognize('NaN', {}).matched.should.eql false
      recognize('NaN', 3).matched.should.eql false
      recognize('NaN', 3.1).matched.should.eql false
      recognize('NaN', '3.1').matched.should.eql false
      recognize('NaN', []).matched.should.eql false
      recognize('NaN', null).matched.should.eql false
      recognize('NaN', undefined).matched.should.eql false
      recognize('NaN', []).matched.should.eql false
      recognize('NaN', {}).matched.should.eql false

    it 'should recognize null', ->
      recognize = recognizer.init typeSystem.init()

      parsed = recognize('Null', null)

      parsed.should.eql
        matched: true
        data: null
        typedata:
          iscontainer: false
          type: 'Null'

      recognize('Null', 3).matched.should.eql false
      recognize('Null', 3.1).matched.should.eql false
      recognize('Null', '3.1').matched.should.eql false
      recognize('Null', []).matched.should.eql false
      recognize('Null', NaN).matched.should.eql false
      recognize('Null', undefined).matched.should.eql false
      recognize('Null', [null]).matched.should.eql false
      recognize('Null', {}).matched.should.eql false

    it 'should recognize undefined', ->
      recognize = recognizer.init typeSystem.init()

      parsed = recognize('Undefined', undefined)

      parsed.should.eql
        matched: true
        data: undefined
        typedata:
          iscontainer: false
          type: 'Undefined'

      recognize('Undefined', 3).matched.should.eql false
      recognize('Undefined', 3.1).matched.should.eql false
      recognize('Undefined', '3.1').matched.should.eql false
      recognize('Undefined', NaN).matched.should.eql false
      recognize('Undefined', null).matched.should.eql false
      recognize('Undefined', []).matched.should.eql false
      recognize('Undefined', [undefined]).matched.should.eql false
      recognize('Undefined', {}).matched.should.eql false
