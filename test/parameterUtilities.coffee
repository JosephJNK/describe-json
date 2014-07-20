{ selectParametersForField, resolveAllPossibleParameters, getTypeNameForField} = require '../public/parameterUtilities'
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

      should.not.exist err
      res.should.match
        typeArg: 'Number'
        staticParameter: 'String'
        dynamicParameter: 'Float'

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

  describe 'getTypeNameForField', ->
    it 'should return the name of the field when given a field with a static type', ->
      params = irrelevant: 'Number'
      fieldData = 'String'

      getTypeNameForField(fieldData, params).should.eql 'String'

    it 'should apply a type parameter when given a parameterized field', ->
      fieldData = 'aParam'
      params = aParam: 'Number'

      getTypeNameForField(fieldData, params).should.eql 'Number'

    it 'should return null when it can\'t resolve a parameterized field', ->
      fieldData = 'aParam'
      params = aDifferentParam: 'Number'

      should.not.exist getTypeNameForField fieldData, params

    it 'should return null when a field resolves to a parameter', ->
      fieldData = 'aParam'
      params = aParam: 'anotherParam'

      should.not.exist getTypeNameForField fieldData, params

    it 'should return the name of the field when given a field with a static parameterized type', ->
      fieldData = 'FieldType': fieldParam: 'fieldParamBinding'
      params =
        fieldParam: 'It would not make sense for this to be used'
        fieldParamBinding: 'The type param that would get passed to this object during parsing'
        irrelevant: 'Number'

      getTypeNameForField(fieldData, params).should.eql 'FieldType'

    it 'should apply a type parameter when given a dynamic parameterized field', ->
      fieldData = someParam: fieldParam: 'fieldParamBinding'
      params =
        someParam: 'FieldType'
        fieldParam: 'It would not make sense for this to be used'
        fieldParamBinding: 'The type param that would get passed to this object during parsing'
        irrelevant: 'Number'

      getTypeNameForField(fieldData, params).should.eql 'FieldType'

    it 'should return null when it can\'t resolve a parameterized field', ->
      fieldData = someParam: fieldParam: 'fieldParamBinding'
      params =
        fieldParam: 'It would not make sense for this to be used'
        fieldParamBinding: 'The type param that would get passed to this object during parsing'
        irrelevant: 'Number'

      should.not.exist getTypeNameForField fieldData, params

    it 'should return null when a field resolves to a parameter', ->
      fieldData = someParam: fieldParam: 'fieldParamBinding'
      params =
        someParam: 'anotherParameter'
        fieldParam: 'It would not make sense for this to be used'
        fieldParamBinding: 'The type param that would get passed to this object during parsing'
        irrelevant: 'Number'


      should.not.exist getTypeNameForField fieldData, params
