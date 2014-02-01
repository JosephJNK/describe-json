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

    typeResolver.addItemToLabelledCollection paramTypeLabel, parameterizedTypeName, collection
    typeResolver.addItemToLabelledCollection typeLabel, typeName, collection
    typeResolver.addItemToLabelledCollection paramTypeclassLabel, parameterizedTypeclassName, collection
    typeResolver.addItemToLabelledCollection typeclassLabel, typeclassName, collection

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
