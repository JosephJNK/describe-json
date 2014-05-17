{ selectParametersForField, applyTypeParametersForField, resolveAllPossibleParameters} = require '../src/parameterUtilities'

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

      parentParameters = aFieldParameter: 'Number'

      parameterizedField =
        'ParameterizedType':
          fieldParameter: 'aFieldParameter'

      [err, res] = selectParametersForField parameterizedField, parentParameters

      should.not.exist err
      res.should.eql fieldParameter: 'Number'

    it 'should be able to handle static, dynamic, and irrelevant parameters', ->

      parentParameters =
        parentParameter: 'Number'
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

    it 'should select a type argument when a field has a parametric type', ->
      parentParameters =
        typeArg: 'Number'
        irrelevant: 'Wheeeee'

      field = 'typeArg'

      [err, res] = selectParametersForField field, parentParameters

      should.not.exist err
      res.should.eql typeArg: 'Number'

    it 'should handle fields with a parametric type and type args', ->
      parentParameters =
        typeArg: 'Number'
        parentParameter: 'Float'
        irrelevant: 'Wheeeee'

      field =
        'typeArg':
          staticParameter: 'String'
          dynamicParameter: 'parentParameter'

      [err, res] = selectParametersForField field, parentParameters

      {inspect} = require 'util'

      should.not.exist err
      res.typeArg.should.eql 'Number'
      res.staticParameter.should.eql 'String'
      res.dynamicParameter.should.eql 'Float'


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

  describe 'trying to resolve parameters for fields', ->

    it 'should resolve any parameters possible', ->

      fieldsObject =
        fieldOne: 'Integer'
        fieldTwo: 'resolvable'
        fieldThree: 'alsoResolvable'
        fieldFour: 'unresolvable'

      params =
        resolvable: 'String'
        alsoResolvable: 'SomeType'

      resolved = resolveAllPossibleParameters fieldsObject, params

      resolved.should.eql
        fieldOne: 'Integer'
        fieldTwo: 'String'
        fieldThree: 'SomeType'
        fieldFour: 'unresolvable'

    it 'should resolve arguments to parameterized fields when possible', ->

      fieldsObject =
        fieldOne:
          'AType':
            first: 'resolvable'
            second: 'unresolvable'
            third: 'Integer'
        fieldTwo:
          'AnotherType':
            first: 'resolvable'
            second: 'alsoResolvable'
            third: 'Number'

      params =
        resolvable: 'String'
        alsoResolvable: 'SomeType'

      resolved = resolveAllPossibleParameters fieldsObject, params

      resolved.should.eql
        fieldOne:
          'AType':
            first: 'String'
            second: 'unresolvable'
            third: 'Integer'
        fieldTwo:
          'AnotherType':
            first: 'String'
            second: 'SomeType'
            third: 'Number'

    it 'should return empty object if the fields its passed are undefined', ->

      fieldsObject = undefined

      params =
        resolvable: 'String'
        alsoResolvable: 'SomeType'

      resolved = resolveAllPossibleParameters fieldsObject, params

      resolved.should.eql {}
