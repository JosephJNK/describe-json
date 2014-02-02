
{getOnlyValueForObject, beginsWithUpperCase, isString} = require './utilities'

module.exports =

  selectParametersForField: (fieldDeclaration, parentParameters) ->

    return [null, {}] if isString fieldDeclaration

    fieldParams = getOnlyValueForObject fieldDeclaration
    staticParams = []
    dynamicParams = []

    for paramName, paramValue of fieldParams
      if beginsWithUpperCase paramValue
        staticParams.push paramName
      else
        dynamicParams.push paramName

    resolvedParams = {}
    resolvedParams[paramName] = fieldParams[paramName] for paramName in staticParams
    resolvedParams[paramName] = parentParameters[paramName] for paramName in dynamicParams

    return [null, resolvedParams]


  applyTypeParametersForField: (fieldTypeData, parameterArguments) ->
    freeParameters = []
    boundParameters = {}

    {inspect} = require 'util'

    console.log inspect parameterArguments

    for paramName, paramArgument of getOnlyValueForObject fieldTypeData

      if beginsWithUpperCase paramArgument
        boundParameters[paramName] = paramArgument
      else
        if parameterArguments[paramArgument]?
          boundParameters[paramName] = parameterArguments[paramArgument]
        else
          freeParameters.push paramName

    console.log inspect freeParameters
    console.log inspect boundParameters

    [freeParameters, boundParameters]


