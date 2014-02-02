
{getOnlyKeyForObject, beginsWithUpperCase, isString} = require './utilities'
{applyTypeParametersForField} = require './parameterUtilities'

{inspect} = require 'util'

createLabelForField = (typeData, typeParameters) ->
  console.log "Making label for #{inspect typeData, depth:null} with params #{inspect typeParameters, {depth: null}}"

  if isString typeData
    isParameter = not beginsWithUpperCase typeData[0]
    if isParameter
      [freeParameters, boundParameters] = applyTypeParametersForField typeData, typeParameters
      fullyResolved = freeParameters.length is 0
      boundParamNames = Object.keys boundParameters
      if boundParamNames.length isnt 0
        console.log 'resolved parameterized type'
        name: boundParamNames[0]
        isparameterized: true
        basetypeisresolved: true
        freeparameters: freeParameters.sort()
        boundparameters: boundParameters
      else
        console.log 'unresolved parameterized type'
        isparameterized: true
        basetypeisresolved: false
        freeparameters: freeParameters.sort()
        boundparameters: boundParameters
    else
      console.log 'nonparameterized type'
      name: typeData
      isparameterized: false
      basetypeisresolved: true
  else
    typeName = getOnlyKeyForObject typeData
    [freeParameters, boundParameters] = applyTypeParametersForField typeData[typeName], typeParameters
    name: typeName
    isparameterized: true
    basetypeisresolved: true
    freeparameters: freeParameters.sort()
    boundparameters: boundParameters

createLabelForType = (typeName, typeData) ->
  hasParameters = typeData.typeparameters? and typeData.typeparameters.length > 0
  name: typeName
  isparameterized: hasParameters
  basetypeisresolved: true
  freeparameters: if hasParameters then typeData.typeparameters.sort() else []
  boundparameters: {}

createLabelForNativeType = (typeName) ->
  name: typeName
  isparameterized: false
  basetypeisresolved: true

createLabelForPattern = (typeName) ->
  name: typeName
  isparameterized: false
  basetypeisresolved: true

getFromCollectionByLabel = (label, collection) ->
  return ['Cannot look up an item with an unresolved name', null] unless label?.name?
  if label.isparameterized
    #TODO: Expand this to be able to cache resolved parameterized types
    item = collection?.parameterized?[label.name]
    if item? then [null, item] else ['No such item found', null]
  else
    item = collection?.unparameterized?[label.name]
    if item? then [null, item] else ['No such item found', null]

addItemToLabelledCollection = (label, item, collection) ->
  collection = {} unless collection
  collection.parameterized = {} unless collection.parameterized?
  collection.unparameterized = {} unless collection.unparameterized?
  collection.resolved = {} unless collection.unparameterized?

  return ["Tried to add an item with an unresolved base type: #{label}", null] unless label.basetypeisresolved

  {name, isparameterized} = label

  if isparameterized
    #TODO: Expand this to be able to cache resolved parameterized types
    collection.parameterized[name] = item
  else
    collection.unparameterized[name] = item
  null

module.exports =
  createLabelForField: createLabelForField
  getParserForType: getFromCollectionByLabel
  addItemToLabelledCollection: addItemToLabelledCollection
  createLabelForType: createLabelForType
  createLabelForTypeclass: createLabelForType
  createLabelForNativeType: createLabelForNativeType
  getFromCollectionByLabel: getFromCollectionByLabel
  createLabelForPattern: createLabelForPattern
