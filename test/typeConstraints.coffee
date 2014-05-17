should = require 'should'
recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'

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

    recognize = recognizer.init system

    data =
      middleField:
        aField:
          string: 'foo'

    matched = recognize 'OuterType', data
    matched.should.eql true


#List of tests: test a valid and invalid declaration for each
#direct match (type A)
#matches subclass (member of typeclass A)
#alternation (maybe call it 'or'?)
#union (maybe call it 'and'?)
#circular reference
