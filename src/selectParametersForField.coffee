
{getOnlyValueForObject, beginsWithUpperCase, isString} = require './utilities'

module.exports = (fieldDeclaration, parentParameters) ->

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
