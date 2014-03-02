
{getOnlyValueForObject, getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'

{inspect} = require 'util'

isResolvedTypeName = (x) -> isString(x) and beginsWithUpperCase(x)
isParameterName = (x) -> isString(x) and !beginsWithUpperCase(x)

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


  applyTypeParametersForField: (fieldDeclaration, parameterArguments) ->
    # freeParameters is a list of unresolved parameters
    # boundParameters are of the form parameterName: resolvedParameterValue
    freeParameters = []
    boundParameters = {}

    if isResolvedTypeName fieldDeclaration
      return [freeParameters, boundParameters]

    if isParameterName fieldDeclaration
      applyFieldTypeAsParameter fieldDeclaration, parameterArguments, freeParameters, boundParameters
      return [freeParameters, boundParameters]

    fieldTypeName = getOnlyKeyForObject fieldDeclaration
    if isParameterName fieldTypeName
      applyFieldTypeAsParameter fieldTypeName, parameterArguments, freeParameters, boundParameters

    applyParametersFromFieldObject fieldDeclaration, parameterArguments, freeParameters, boundParameters

    [freeParameters, boundParameters]

  resolveAllPossibleParameters: resolveAllPossibleParameters
