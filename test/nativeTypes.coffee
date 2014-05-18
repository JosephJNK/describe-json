recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  describe 'error messages', ->

    it 'should tell you when you try to access an unregistered type', ->
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()
      try
        recognize 'Invalid', {}
      catch e
        e.should.eql "Type Invalid wasn't registered!"


  describe 'basic types', ->

    it 'should recognize an Integer', ->
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()

      parsed = recognize('Integer', 3)

      parsed.should.eql
        matched: true
        data: 3
        typedata:
          type: 'Integer'
          iscontainer: false

      recognize('Integer', 3.1).matched.should.eql false
      recognize('Integer', '3').matched.should.eql false
      recognize('Integer', NaN).matched.should.eql false
      recognize('Integer', {3}).matched.should.eql false
      recognize('Integer', [3]).matched.should.eql false
      recognize('Integer', null).matched.should.eql false
      recognize('Integer', undefined).matched.should.eql false
      recognize('Integer', []).matched.should.eql false
      recognize('Integer', {}).matched.should.eql false

    it 'should recognize a Float', ->
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()
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
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()
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
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()
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
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()

      parsed = recognize('NaN', NaN)

      parsed.matched.should.eql true
      #NaN != NaN yaaaaaaaay
      isNaN(parsed.data).should.eql true
      parsed.typedata.type.should.eql 'NaN'
      parsed.typedata.iscontainer.should.eql false

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
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()

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
      system = typeSystem.init()
      system.generateParsers()
      recognize = system.getRecognizer()

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
