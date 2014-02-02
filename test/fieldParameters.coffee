{selectParametersForField, applyTypeParametersForField} = require '../src/parameterUtilities'
should = require 'should'

describe 'Field parameter resolution', ->

  describe 'selecting parameters', ->

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

  describe 'applying parameters', ->

    it 'should select free and bound parameters for a field', ->

      fieldData =
        'ParameterizedType':
          boundParam: 'paramArg'
          staticParam: 'String'
          freeParam: 'anotherArg'
          anotherFreeParam: 'yetAnotherArg'

      params =
        paramArg: 'Number'
        irrelevant: 'Integer'

      [freeParameters, boundParameters] = applyTypeParametersForField fieldData, params

      freeParameters.should.includeEql 'freeParam'
      freeParameters.should.includeEql 'anotherFreeParam'

      boundParameters.boundParam.should.eql 'Number'
      boundParameters.staticParam.should.eql 'String'


    it 'should be able to handle parameterized types', ->

      parameterizedField =
        'paramType':
          fieldParameter: 'paramArg'
          staticParam: 'String'
          unresolved: 'unknown'

      params =
        paramType: 'SomeType'
        paramArg: 'Number'
        irrelevant: 'Integer'

      [freeParameters, boundParameters] = applyTypeParametersForField parameterizedField, params

      freeParameters.should.includeEql 'unresolved'

      boundParameters.paramType.should.eql 'SomeType'
      boundParameters.staticParam.should.eql 'String'
      boundParameters.fieldParameter.should.eql 'Number'


    it 'should handle taking a static type string as input', ->

      fieldData = 'String'

      params =
        paramArg: 'Number'
        irrelevant: 'Integer'

      [freeParameters, boundParameters] = applyTypeParametersForField fieldData, params

      freeParameters.should.eql []
      boundParameters.should.eql {}

    it 'should handle taking a parameter name string as input', ->

      fieldData = 'paramArg'

      params =
        paramArg: 'Number'
        irrelevant: 'Integer'

      [freeParameters, boundParameters] = applyTypeParametersForField fieldData, params

      freeParameters.should.eql []
      boundParameters.should.eql paramArg: 'Number'


    it 'should handle taking an unresolvable parameter name string as input', ->

      fieldData = 'paramArg'

      params =
        irrelevant: 'Integer'

      [freeParameters, boundParameters] = applyTypeParametersForField fieldData, params

      freeParameters.should.eql ['paramArg']
      boundParameters.should.eql {}

