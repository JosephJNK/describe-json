selectParametersForField = require '../src/selectParametersForField'
should = require 'should'

describe 'Field parameter resolution', ->

  it 'should be able to apply static parameters to a field', ->

    parameterizedField =
      'ParameterizedType':
        fieldParameter: 'Number'

    [err, res] = selectParametersForField parameterizedField, {}

    should.not.exist err
    res.should.eql fieldParameter: 'Number'

  it 'should be able to apply containing type parameters to a parametrically typed field', ->

    parentParameters = fieldParameter: 'Number'

    parameterizedField =
      'ParameterizedType':
        fieldParameter: 'fieldParameter'

    [err, res] = selectParametersForField parameterizedField, parentParameters

    should.not.exist err
    res.should.eql fieldParameter: 'Number'

  it 'should be able to handle static, dynamic, and irrelevant parameters', ->

    parentParameters =
      dynamicParameter: 'Number'
      irrelevant: 'Wheeeee'

    parameterizedField =
      'ParameterizedType':
        staticParameter: 'String'
        dynamicParameter: 'parentParameter'

    [err, res] = selectParametersForField parameterizedField, parentParameters

    should.not.exist err
    res.should.eql staticParameter: 'String', dynamicParameter: 'Number'

  it 'should return an empty object when passed a nonparameterized field', ->
    parentParameters =
      irrelevant: 'Wheeeee'
      alsoIrrelevant: 'Woooooo'

    plainField = 'Number'

    [err, res] = selectParametersForField plainField, parentParameters

    should.not.exist err
    res.should.eql {}

