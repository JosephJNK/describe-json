
{getOnlyValueForObject, getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'

{inspect} = require 'util'

isResolvedTypeName = (x) -> isString(x) and beginsWithUpperCase(x)
isParameterName = (x) -> isString(x) and !beginsWithUpperCase(x)

# TODO: There is no way this should be as gnarly as it is... it's probably a symptom of a poorly defined interface
#       Cleaning up and normalizing the ways these methods are called would probably allow this module to be simplified

applyParametersFromFieldObject = (fieldObject, parameterArguments, freeParameters, boundParameters) ->
  for paramName, paramArgument of getOnlyValueForObject fieldObject
    if isResolvedTypeName paramArgument
      boundParameters[paramName] = paramArgument
    else
      resolvedArgument = parameterArguments[paramArgument]
      applyParameterArgsForPolymorphicType paramName, resolvedArgument, freeParameters, boundParameters

applyParameterArgsForPolymorphicType = (paramName, resolvedArgument, freeParameters, boundParameters) ->
  if resolvedArgument?
    boundParameters[paramName] = resolvedArgument
  else
    freeParameters.push paramName

applyFieldTypeAsParameter = (typeName, parameterArguments, freeParameters, boundParameters) ->
  if parameterArguments[typeName]?
    boundParameters[typeName] = parameterArguments[typeName]
  else
    freeParameters.push typeName

selectFieldTypeAsParameter = (fieldType, parentParameters) ->
  if parentParameters[fieldType]?
    result = {}
    result[fieldType] = parentParameters[fieldType]
    return [null, result]
  else
    return [null, {}]

selectResolvedFieldParameters = (fieldParameters, parentParameters, resolvedParameters) ->
  for paramName, paramValue of fieldParameters
    if beginsWithUpperCase paramValue
      resolvedParameters[paramName] = fieldParameters[paramName]
    else
      resolvedParameters[paramName] = parentParameters[paramValue]

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

  # binds as many parameters as possible to the declared field
  selectParametersForField: (fieldDeclaration, parentParameters) ->
    # resolvedParams are of the form parameterName: resolvedParameterValue

    if isResolvedTypeName fieldDeclaration
      return [null, {}]

    if isParameterName fieldDeclaration
      return selectFieldTypeAsParameter fieldDeclaration, parentParameters

    fieldName = getOnlyKeyForObject fieldDeclaration
    resolvedParams = {}

    if isParameterName fieldName
      resolvedParams[fieldName] = parentParameters[fieldName]

    selectResolvedFieldParameters fieldDeclaration[fieldName], parentParameters, resolvedParams

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
