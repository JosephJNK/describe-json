typeResolver = require '../src/typeResolver'
should = require 'should'

describe 'Type Resolver', ->

  it 'should be able to store and retrieve items based on type and typeclass data', ->

    parameterizedTypeName = 'ParameterizedType'
    parameterizedType =
      typeparameters: ['fieldParameter']
      fields:
        parameterized: 'fieldParameter'

    typeName = 'PlainType'
    type =
      fields:
        parameterized: 'String'

    typeclassName = 'InnerTypeclass'
    typeclass = {}

    parameterizedTypeclassName = 'WrapperTypeclass'
    parameterizedTypeclass =
      typeparameters: ['outerParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'outerParameter'

    paramTypeLabel = typeResolver.createLabelForType parameterizedTypeName, parameterizedType
    paramTypeLabel.isparameterized.should.eql true
    typeLabel = typeResolver.createLabelForType typeName, type
    typeLabel.isparameterized.should.eql false
    typeclassLabel = typeResolver.createLabelForTypeclass typeclassName, typeclass
    typeclassLabel.isparameterized.should.eql false
    paramTypeclassLabel = typeResolver.createLabelForTypeclass parameterizedTypeclassName, parameterizedTypeclass
    paramTypeclassLabel.isparameterized.should.eql true

    collection = {}

    err = typeResolver.addItemToLabelledCollection paramTypeLabel, parameterizedTypeName, collection
    should.not.exist err
    err = typeResolver.addItemToLabelledCollection typeLabel, typeName, collection
    should.not.exist err
    err = typeResolver.addItemToLabelledCollection paramTypeclassLabel, parameterizedTypeclassName, collection
    should.not.exist err
    err = typeResolver.addItemToLabelledCollection typeclassLabel, typeclassName, collection
    should.not.exist err

    [err, res] = typeResolver.getFromCollectionByLabel paramTypeLabel, collection
    should.not.exist err
    res.should.eql parameterizedTypeName

    [err, res] = typeResolver.getFromCollectionByLabel typeLabel, collection
    should.not.exist err
    res.should.eql typeName

    [err, res] = typeResolver.getFromCollectionByLabel paramTypeclassLabel, collection
    should.not.exist err
    res.should.eql parameterizedTypeclassName

    [err, res] = typeResolver.getFromCollectionByLabel typeclassLabel, collection
    should.not.exist err
    res.should.eql typeclassName


  it 'should be able to label a field with a parametric type', ->

    parameterizedField = parameterized: 'fieldParameter'
    typeParameters = fieldParameter: 'Number', irrelevant: 'String'
    resolvedLabel = typeResolver.createLabelForField parameterizedField, typeParameters
    resolvedLabel.name.should.eql 'Number'
    resolvedLabel.isparameterized.should.eql true
    resolvedLabel.basetypeisresolved.should.eql true
    resolvedLabel.freeparameters.should.eql []
    resolvedLabel.boundparameters.should.eql {}


  it 'should be able to label a nonparameterized field', ->

    nonParameterizedField = nonparameterized: 'String'
    typeParameters = fieldParameter: 'Number', irrelevant: 'String'

    resolvedLabel = typeResolver.createLabelForField nonParameterizedField, typeParameters
    resolvedLabel.name.should.eql 'String'
    resolvedLabel.isparameterized.should.eql false
    resolvedLabel.basetypeisresolved.should.eql true
    resolvedLabel.freeparameters.should.eql []
    resolvedLabel.boundparameters.should.eql {}


  it 'should be able to label a field which takes a type parameter', ->

    typeParameters = fieldParameter: 'Number', irrelevant: 'String'

    typedParameterizedField =
      parameterized:
        'ParameterizedType':
          innerParameter: 'fieldParameter'
          unresolvedParameter: 'unresolved'

    resolvedLabel = typeResolver.createLabelForField typedParameterizedField, typeParameters
    resolvedLabel.name.should.eql 'ParameterizedType'
    resolvedLabel.isparameterized.should.eql true
    resolvedLabel.basetypeisresolved.should.eql true
    resolvedLabel.freeparameters.should.eql ['unresolvedParameter']
    resolvedLabel.boundparameters.should.eql innerParameter: 'Number'


  it 'should be able to label a parameterized field which takes type parameters', ->

    reallyParameterizedField =
      parameterized:
        'parameterizedType':
          innerParameter: 'fieldParameter'
          unresolvedParameter: 'unresolved'

    typeParameters = parameterizedType: 'SomeType', fieldParameter: 'Number', irrelevant: 'String'
    resolvedLabel = typeResolver.createLabelForField reallyParameterizedField, typeParameters
    resolvedLabel.name.should.eql 'SomeType'
    resolvedLabel.isparameterized.should.eql true
    resolvedLabel.basetypeisresolved.should.eql true
    resolvedLabel.freeparameters.should.eql ['unresolvedParameter']
    resolvedLabel.boundparameters.innerParameter.should.eql 'Number'
    resolvedLabel.boundparameters.parameterizedType.should.eql 'SomeType'


  it 'should be able to label an unresolved parameterized field which takes type parameters', ->

    reallyParameterizedField =
      parameterized:
        'parameterizedType':
          innerParameter: 'fieldParameter'
          unresolvedParameter: 'unresolved'

    typeParameters = fieldParameter: 'Number', irrelevant: 'String'

    resolvedLabel = typeResolver.createLabelForField reallyParameterizedField, typeParameters

    resolvedLabel.isparameterized.should.eql true
    resolvedLabel.basetypeisresolved.should.eql false
    resolvedLabel.freeparameters.should.includeEql 'unresolvedParameter'
    resolvedLabel.freeparameters.should.includeEql 'parameterizedType'
    resolvedLabel.boundparameters.should.eql innerParameter: 'Number'
