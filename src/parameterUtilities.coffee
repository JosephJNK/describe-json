
{getOnlyValueForObject, getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'

{inspect} = require 'util'

isResolvedTypeName = (x) -> isString(x) and beginsWithUpperCase(x)
isParameterName = (x) -> isString(x) and !beginsWithUpperCase(x)

selectFieldTypeAsParameter = (fieldType, parentParameters) ->
  if parentParameters[fieldType]?
    result = {}
    result[fieldType] = parentParameters[fieldType]
    return [null, result]
  else
    return [null, {}]

resolveAllPossibleParameters = (fieldsObj, parameterArguments) ->
  return {} if fieldsObj is undefined

  results = {}
  for fieldName, fieldValue of fieldsObj
    if isString fieldValue
      if isParameterName(fieldValue) and parameterArguments[fieldValue]?
        results[fieldName] = parameterArguments[fieldValue]
      else
        results[fieldName] = fieldValue
    else
      results[fieldName] = resolveAllPossibleParameters fieldValue, parameterArguments
  results

module.exports =

  # returns an object containing the mapping for every resolvable type parameter for this field
  # resolvedParams are of the form parameterName: resolved type for this parameter
  selectParametersForField: (fieldDeclaration, parentParameters) ->

    # There's no parameters if we're given a statically typed field
    return [null, {}] if isResolvedTypeName fieldDeclaration

    # Our only parameter is for the type of the field, so resolve and return that
    return selectFieldTypeAsParameter fieldDeclaration, parentParameters if isParameterName fieldDeclaration

    fieldName = getOnlyKeyForObject fieldDeclaration
    resolvedParams = {}

    if isParameterName fieldName
      resolvedParams[fieldName] = parentParameters[fieldName]

    for paramName, paramValue of fieldDeclaration[fieldName]
      if beginsWithUpperCase paramValue
        resolvedParams[paramName] = paramValue # This parameter has a static type
      else
        resolvedParams[paramName] = parentParameters[paramValue] # This parameter has its type passed through

    return [null, resolvedParams]

  resolveAllPossibleParameters: resolveAllPossibleParameters

  getTypeNameForField: (fieldData, parameters) ->
    if isString(fieldData) and beginsWithUpperCase fieldData #The field is a static type
      return fieldData
    if isString(fieldData) and not beginsWithUpperCase fieldData #The field is a parameter
      resolvedFieldName = parameters[fieldData]
      return resolvedFieldName if resolvedFieldName? and beginsWithUpperCase resolvedFieldName
      return null #we were not able to fully resolve the type

    # The field data is not a string, so it's an object-- key field type, value field params
    name = getOnlyKeyForObject fieldData
    if beginsWithUpperCase name
      return name #The name of the parameterized type is static
    else
      resolvedFieldName = parameters[name]
      return resolvedFieldName if resolvedFieldName? and beginsWithUpperCase resolvedFieldName
      return null #we were not able to fully resolve the type
