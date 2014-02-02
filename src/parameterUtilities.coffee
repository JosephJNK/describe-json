
{getOnlyValueForObject, getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'

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


  applyTypeParametersForField: (fieldTypeData, parameterArguments) ->
    freeParameters = []
    boundParameters = {}

    if isString fieldTypeData
      unless beginsWithUpperCase fieldTypeData

        if parameterArguments[fieldTypeData]?
          boundParameters[fieldTypeData] = parameterArguments[fieldTypeData]
        else
          freeParameters.push fieldTypeData

      return [freeParameters, boundParameters] 

    paramType = getOnlyKeyForObject fieldTypeData

    unless beginsWithUpperCase paramType
      if parameterArguments[paramType]?
        boundParameters[paramType] = parameterArguments[paramType]
      else
        freeParameters.push paramType


    for paramName, paramArgument of getOnlyValueForObject fieldTypeData

      if beginsWithUpperCase paramArgument
        boundParameters[paramName] = paramArgument
      else
        if parameterArguments[paramArgument]?
          boundParameters[paramName] = parameterArguments[paramArgument]
        else
          freeParameters.push paramName

    [freeParameters, boundParameters]
