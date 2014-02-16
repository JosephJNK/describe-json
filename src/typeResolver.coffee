
{getOnlyKeyForObject, getOnlyValueForObject, beginsWithUpperCase, isString} = require './utilities'
{applyTypeParametersForField} = require './parameterUtilities'

{inspect} = require 'util'

createLabelForField = (typeData, typeParameters) ->

  {inspect} = require 'util'
  console.log '\n'
  console.log "typeData: #{inspect typeData, depth:null}"
  console.log "typeParameters: #{inspect typeParameters, depth:null}"
  console.log '\n'

  fieldData = getOnlyValueForObject typeData

  if isString fieldData
    isParameter = not beginsWithUpperCase fieldData[0]
    if isParameter
      [freeParameters, boundParameters] = applyTypeParametersForField fieldData, typeParameters
      fullyResolved = freeParameters.length is 0
      if Object.keys(boundParameters).length isnt 0
        name: getOnlyValueForObject boundParameters
        isparameterized: false
        basetypeisresolved: true
        freeparameters: []
        boundparameters: {}
      else
        isparameterized: true
        basetypeisresolved: false
        freeparameters: freeParameters.sort()
        boundparameters: boundParameters
    else
      name: fieldData
      isparameterized: false
      basetypeisresolved: true
      freeparameters: []
      boundparameters: {}
  else
    typeName = getOnlyKeyForObject fieldData
    [freeParameters, boundParameters] = applyTypeParametersForField fieldData, typeParameters

    resolvedName = if boundParameters[typeName]? then boundParameters[typeName] else typeName

    name: resolvedName
    isparameterized: true
    basetypeisresolved: beginsWithUpperCase resolvedName
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
  freeparameters: []
  boundparameters: {}

createLabelForPattern = (typeName) ->
  name: typeName
  isparameterized: false
  basetypeisresolved: true
  freeparameters: []
  boundparameters: {}

getFromCollectionByLabel = (label, collection) ->
  return ['Cannot look up an item with an unresolved name', null] unless label?.name?
  #TODO: this is terrible. I'm beginning to consider removing the isparameterized field.
  #Also this whole workflow is overly gnarly at this point.
  if label.isparameterized
    console.log "got a parameterized type for #{label.name}"
    #TODO: Expand this to be able to cache resolved parameterized types
    item = collection?.parameterized?[label.name]
    console.log "item: #{inspect item}"
    if item? then [null, item] else ['No such item found', null]
  else
    item = collection?.unparameterized?[label.name]
    console.log "got an unparameterized type for #{label.name}"
    console.log "item: #{inspect item}"
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
