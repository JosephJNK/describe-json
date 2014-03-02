recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'
should = require 'should'

{inspect} = require 'util'

describe 'type parameters', ->

  it 'should be registerable with the type system', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    system = typeSystem.init()
    error = system.register parameterizedType

    should.not.exist error

    system.types.ParameterizedType.should.eql parameterizedType.newtype

  it 'should allow for a types fields to vary across containers', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    numberOuterType = newtype:
      name: 'NumberOuterType'
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'Number'
        nonparameterizedField: 'String'

    stringOuterType = newtype:
      name: 'StringOuterType'
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'String'
        nonparameterizedField: 'Number'

    system = typeSystem.init()
    system.register numberOuterType
    system.register parameterizedType
    system.register stringOuterType
    recognize = recognizer.init system

    firstData =
      parameterizedField:
        intField: 1
        innerParameterized: 1.5
      nonparameterizedField: 'foo'

    firstMatched = recognize 'NumberOuterType', firstData

    firstMatched.matched.should.eql true
    firstMatched.data.should.eql firstData
    firstMatched.typedata.type.should.eql 'NumberOuterType'
    firstMatched.typedata.typeparameters.should.eql {}
    firstMatched.typedata.iscontainer.should.eql true

    firstMatched.typedata.fields.parameterizedField.type.should.eql 'ParameterizedType'
    firstMatched.typedata.fields.parameterizedField.typeparameters.should.eql {fieldParameter: 'Number'}
    firstMatched.typedata.fields.parameterizedField.iscontainer.should.eql true

    firstMatched.typedata.fields.parameterizedField.fields.intField.type.should.eql 'Integer'
    firstMatched.typedata.fields.parameterizedField.fields.intField.iscontainer.should.eql false

    firstMatched.typedata.fields.parameterizedField.fields.innerParameterized.type.should.eql 'Number'
    firstMatched.typedata.fields.parameterizedField.fields.innerParameterized.iscontainer.should.eql false

    firstMatched.typedata.fields.nonparameterizedField.type.should.eql 'String'
    firstMatched.typedata.fields.nonparameterizedField.iscontainer.should.eql false

    secondData =
      parameterizedField:
        intField: 1
        innerParameterized: 'bar'
      nonparameterizedField: -2

    secondMatched = recognize 'StringOuterType', secondData

    secondMatched.matched.should.eql true
    secondMatched.data.should.eql secondData
    secondMatched.typedata.type.should.eql 'StringOuterType'
    secondMatched.typedata.typeparameters.should.eql {}
    secondMatched.typedata.iscontainer.should.eql true

    secondMatched.typedata.fields.parameterizedField.type.should.eql 'ParameterizedType'
    secondMatched.typedata.fields.parameterizedField.typeparameters.should.eql {fieldParameter: 'String'}
    secondMatched.typedata.fields.parameterizedField.iscontainer.should.eql true

    secondMatched.typedata.fields.parameterizedField.fields.intField.type.should.eql 'Integer'
    secondMatched.typedata.fields.parameterizedField.fields.intField.iscontainer.should.eql false

    secondMatched.typedata.fields.parameterizedField.fields.innerParameterized.type.should.eql 'String'
    secondMatched.typedata.fields.parameterizedField.fields.innerParameterized.iscontainer.should.eql false

    secondMatched.typedata.fields.nonparameterizedField.type.should.eql 'Number'
    secondMatched.typedata.fields.nonparameterizedField.iscontainer.should.eql false


describe.skip 'waiting for resolveTypeGraph to produce parameterized types', ->

  it 'should let a typeclass contain a parametric type', ->

    console.log '----------------------------------------'


    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    wrapperTypeclass = newtypeclass:
      name: 'WrapperTypeclass'
      typeparameters: ['passedThroughParameter', 'ownParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'passedThroughParameter'
        polymorphicField: 'ownParameter'
        floatField: 'Float'

    outerType = newtype:
      name: 'OuterType'
      typeclasses: [ {
        'WrapperTypeclass': { passedThroughParameter: 'String', ownParameter: 'Integer'}
      } ]

    data =
      parameterizedField:
        intField: 5
        innerParameterized: 'foo'
      polymorphicField: -3
      floatField: 2.5

    system = typeSystem.init()
    system.register wrapperTypeclass
    system.register parameterizedType
    err = system.register outerType
    should.not.exist err
    recognize = recognizer.init system

    matched = recognize 'OuterType', data

    matched.matched.should.eql true
    matched.data.should.eql firstData
    matched.typedata.type.should.eql 'OuterType'
    matched.typedata.typeparameters.should.eql {}
    matched.typedata.iscontainer.should.eql true

    matched.typedata.fields.parameterizedField.type.should.eql 'ParameterizedType'
    matched.typedata.fields.parameterizedField.typeparameters.should.eql {fieldParameter: 'String'}
    matched.typedata.fields.parameterizedField.iscontainer.should.eql true

    matched.typedata.fields.parameterizedField.fields.intField.type.should.eql 'Integer'
    matched.typedata.fields.parameterizedField.fields.intField.iscontainer.should.eql false

    matched.typedata.fields.parameterizedField.fields.innerParameterized.type.should.eql 'String'
    matched.typedata.fields.parameterizedField.fields.innerParameterized.iscontainer.should.eql false

    matched.typedata.fields.polymorphicField.type.should.eql 'Integer'
    matched.typedata.fields.polymorphicField.iscontainer.should.eql false

    matched.typedata.fields.floatField.type.should.eql 'Float'
    matched.typedata.fields.floatField.iscontainer.should.eql false


describe.skip 'type parameters', ->

  it 'should let a typclass pass parameters to a typeclass which it extends', ->

  it 'should allow parameters to be passed through multiple levels of wrappers', ->

  it 'should let a field take multiple type parameters', ->

  it 'should have validations during registration', ->
