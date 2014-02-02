recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'
should = require 'should'

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
          'ParameterizedField':
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
    firstMatched.typedata.iscontainer.should.eql true

    firstMatched.typedata.fields.parameterizedField.type.should.eql 'ParameterizedType'
    firstMatched.typedata.fields.parameterizedField.typeParameters.should.eql {fieldParameter: 'Number'}
    firstMatched.typedata.fields.parameterizedField.iscontainer.should.eql true

    firstMatched.typedata.fields.parameterizedField.fields.intField.type.should.eql 'Integer'
    firstMatched.typedata.fields.parameterizedField.fields.intField.iscontainer.should.eql false

    firstMatched.typedata.fields.parameterizedField.fields.innerParameterized.type.should.eql 'Integer'
    firstMatched.typedata.fields.parameterizedField.fields.innerParameterized.iscontainer.should.eql false

    firstMatched.typedata.fields.nonparameterizedField.type.should.eql 'String'
    firstMatched.typedata.fields.nonparameterizedField.iscontainer.should.eql false

    secondData =
      parameterizedField:
        intField: 1
        innerParameterized: 'bar'
      nonparameterizedField: -2

    secondMatched = recognize 'NumberOuterType', firstData

    secondMatched.matched.should.eql true
    secondMatched.data.should.eql firstData
    secondMatched.typedata.type.should.eql 'StringOuterType'
    secondMatched.typedata.iscontainer.should.eql true

    secondMatched.typedata.fields.parameterizedField.type.should.eql 'ParameterizedType'
    secondMatched.typedata.fields.parameterizedField.typeParameters.should.eql {fieldParameter: 'String'}
    secondMatched.typedata.fields.parameterizedField.iscontainer.should.eql true

    secondMatched.typedata.fields.parameterizedField.fields.intField.type.should.eql 'Integer'
    secondMatched.typedata.fields.parameterizedField.fields.intField.iscontainer.should.eql false

    secondMatched.typedata.fields.parameterizedField.fields.innerParameterized.type.should.eql 'String'
    secondMatched.typedata.fields.parameterizedField.fields.innerParameterized.iscontainer.should.eql false

    secondMatched.typedata.fields.nonparameterizedField.type.should.eql 'Number'
    secondMatched.typedata.fields.nonparameterizedField.iscontainer.should.eql false


describe.skip 'type parameters', ->
  it 'something like this', ->

    #add in a typeclass that declares 'typeclassParameter'
    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter', 'passedParameter']
      fields:
        intField: 'Integer'
        innerParameterized:
          'fieldParameter':
            typeclassParameter: 'passedParameter'


  it 'should allow parameters to be passed through multiple levels of wrappers', ->

  it 'should handle fields with multiple type parameters', ->

  it 'should let a type class take type parameters', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        parameterizedField: 'fieldParameter'

    wrapperTypeclass = newtypeclass:
      name: 'WrapperTypeclass'
      typeparameters: ['outerParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'outerParameter'

    outerType = newtype:
      name: 'OuterType'
      typeclasses: [ {
        'WrapperTypeclass': { outerParameter: 'String'}
      } ]

    throw 'remember to add assertions here'

  it 'should have validations during registration', ->
    true.should.eql false


