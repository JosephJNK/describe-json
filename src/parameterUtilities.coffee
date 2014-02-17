
{getOnlyValueForObject, getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'

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

module.exports =

  selectParametersForField: (fieldDeclaration, parentParameters) ->

    if isString fieldDeclaration
      if not beginsWithUpperCase(fieldDeclaration) and parentParameters[fieldDeclaration]?
        result = {}
        result[fieldDeclaration] = parentParameters[fieldDeclaration]
        return [null, result]
      return [null, {}]

    fieldName = getOnlyKeyForObject fieldDeclaration
    console.log fieldName
    fieldParams = fieldDeclaration[fieldName]
    resolvedParams = {}

    resolvedParams[fieldName] = parentParameters[fieldName] unless beginsWithUpperCase fieldName

    for paramName, paramValue of fieldParams
      if beginsWithUpperCase paramValue
        resolvedParams[paramName] = fieldParams[paramName]
      else
        resolvedParams[paramName] = parentParameters[paramValue]

    return [null, resolvedParams]


  applyTypeParametersForField: (fieldDeclaration, parameterArguments) ->
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
