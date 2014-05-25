should = require 'should'
recognizer = require '../public/recognizer'
typeSystem = require '../public/typeSystem'

describe 'Constraints on type parameters', ->

  it 'should allow a type parameter matching its constraints to be used', ->

    outerType = newtype:
      name: 'OuterType'
      fields:
        middleField:
          'MiddleType':
            aParam: 'InnerType'

    middleType = newtype:
      name: 'MiddleType'
      typeparameters:
        aParam: 'InnerType'
      fields:
        aField: 'aParam'

    innerType = newtype:
      name: 'InnerType'
      fields:
        string: 'String'

    system = typeSystem.init()
    error1 = system.register outerType
    should.not.exist error1
    error2 = system.register middleType
    should.not.exist error2
    error3 = system.register innerType
    should.not.exist error3

    system.generateParsers()
    recognize = system.getRecognizer()

    data =
      middleField:
        aField:
          string: 'foo'

    recognized = recognize 'OuterType', data
    recognized.matched.should.eql true


#List of tests: test a valid and invalid declaration for each
#direct match (type A)
#matches subclass (member of typeclass A)
#alternation (maybe call it 'or'?)
#union (maybe call it 'and'?)
#circular reference
