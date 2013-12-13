recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

describe 'recognizer', ->

  it 'should recognize an Int', ->
    recognize = recognizer.init typeSystem.init()
    recognize('Int', 3).should.eql true
    recognize('Int', 3.1).should.eql false
    recognize('Int', '3').should.eql false
    recognize('Int', NaN).should.eql false
    recognize('Int', {3}).should.eql false
    recognize('Int', [3]).should.eql false

  it 'should recognize a Float', ->
    recognize = recognizer.init typeSystem.init()
    recognize('Float', 3.1).should.eql true
    recognize('Float', 3).should.eql false
    recognize('Float', '3.1').should.eql false
    recognize('Float', NaN).should.eql false
    recognize('Float', {3.1}).should.eql false
    recognize('Float', [3.1]).should.eql false

  it 'should recognize a Number', ->
    recognize = recognizer.init typeSystem.init()
    recognize('Number', 3.1).should.eql true
    recognize('Number', 3).should.eql true
    recognize('Number', '3.1').should.eql false
    recognize('Number', NaN).should.eql false
    recognize('Number', {3.1}).should.eql false
    recognize('Number', [3.1]).should.eql false

  it 'should recognize a String', ->
    recognize = recognizer.init typeSystem.init()
    recognize('String', '3').should.eql true
    recognize('String', 3).should.eql false
    recognize('String', 3.1).should.eql false
    recognize('String', NaN).should.eql false
    recognize('String', {'3.1'}).should.eql false
    recognize('String', ['3', '.', '1']).should.eql false

  it 'should recognize an Array', ->
    recognize = recognizer.init typeSystem.init()
    recognize('Array', []).should.eql true
    recognize('Array', 3).should.eql false
    recognize('Array', 3.1).should.eql false
    recognize('Array', '3.1').should.eql false
    recognize('Array', NaN).should.eql false
    recognize('Array', {3.1}).should.eql false

  it 'should recognize an Object', ->
    recognize = recognizer.init typeSystem.init()
    recognize('Object', {}).should.eql true
    recognize('Object', 3).should.eql false
    recognize('Object', 3.1).should.eql false
    recognize('Object', '3.1').should.eql false
    recognize('Object', NaN).should.eql false
    recognize('Object', []).should.eql false

  it 'should recognize a NaN', ->
    recognize = recognizer.init typeSystem.init()
    recognize('NaN', NaN).should.eql true
    recognize('NaN', {}).should.eql false
    recognize('NaN', 3).should.eql false
    recognize('NaN', 3.1).should.eql false
    recognize('NaN', '3.1').should.eql false
    recognize('NaN', []).should.eql false
