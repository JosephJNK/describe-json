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

    err = system.generateParsers()
    should.not.exist err
    recognize = system.getRecognizer()

    data =
      middleField:
        aField:
          string: 'foo'

    recognized = recognize 'OuterType', data
    recognized.matched.should.eql true

  it 'should reject a type parameter that mismatches an explicit type constraint', ->
    outerType = newtype:
      name: 'OuterType'
      fields:
        middleField:
          'MiddleType':
            aParam: 'WrongInnerType'

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

    wrongInnerType = newtype:
      name: 'WrongInnerType'
      fields:
        string: 'String'

    system = typeSystem.init()
    error1 = system.register outerType
    should.not.exist error1
    error2 = system.register middleType
    should.not.exist error2
    error3 = system.register innerType
    should.not.exist error3
    error4 = system.register wrongInnerType
    should.not.exist error3

    err = system.generateParsers()
    err.should.match
      parameterConstraint:
        parameter: {aParam: 'WrongInnerType'}
        containingType: 'OuterType'


  it.skip 'should reject a type parameter that mismatches an interface constraint', ->

  it.skip 'should allow a parameter which is a subtype of a type constraint', ->

  it.skip 'should allow a parameter which is a member of an interface constraint', ->

  it.skip 'should properly accept types when there is a circular dependency', ->
    #One type is a subtype of A, with a parameter that is constrained to B
    #Another is a type of B, with a parameter that is constrained to A
    #It should be possible to pass them to each other

  it.skip 'should properly reject types when there is a circular dependency', ->
    #Similar to above, but pass a mismatched type somewhere in the chain

  it.skip 'should reject a type parameter which is not part of an alternation list', ->
    #Put both interface and concrete type which has subclasses in list

  it.skip 'should accept a type parameter which is part of an alternation list', ->
    #Check direct, subtype, and interface membership matches

  it.skip 'should reject a type parameter which does not fulfill all parts of a union constraint', ->
    #Check when it matches some but not all

  it.skip 'should accept a type parameter which is part of an alternation list', ->
    #Check direct, subtype, and interface membership matches

  it.skip 'should properly accept type parameters when union, alternation, and circular dependencies are used', ->

  it.skip 'should properly reject type parameters when union, alternation, and circular dependencies are used', ->

  it.skip 'should allow union and alternation to be nested', ->
