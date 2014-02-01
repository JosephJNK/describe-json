applyTypeParameters = (fieldParameters, parameterArguments) ->
  freeParameters = []
  boundParameters = {}

  for paramName, paramArgument of fieldParameters
    resolvedParameter = parameterArguments[paramName]
    if resolvedParameter isnt undefined
      boundParameters[paramName] = resolvedParameter
    else
      freeParameters.push paramName

  [freeParameters, boundParameters]

createLabelForField = (typeData, typeParameters) ->
  isString = Object.prototype.toString.call(typeData) is '[object String]'
  if isString
    isParameter = typeData[0].toUpperCase() isnt typeData[0]
    if isParameter
      [freeParameters, boundParameters] = applyTypeParameters typeData, typeParameters
      fullyResolved = freeParameters.length is 0
      boundParamNames = Object.keys(x)
      if boundParamNames.length isnt 0
        name: boundParamNames[0]
        isparameterized: true
        basetypeisresolved: true
        freeparameters: freeParameters.sort()
        boundparameters: boundParameters
      else
        isparameterized: true
        basetypeisresolved: false
        freeparameters: freeParameters.sort()
        boundparameters: boundParameters
    else
      name: typeData
      isparameterized: false
      basetypeisresolved: true
  else
    typeName = getOnlyKeyForObject typeData
    [freeParameters, boundParameters] = applyTypeParameters typeData[typeName], typeParameters
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

  return triedToAddInvalidObject label unless label.basetypeisresolved

  {name, isparameterized} = label

  if isparameterized
    #TODO: Expand this to be able to cache resolved parameterized types
    collection.parameterized[name] = item
  else
    collection.unparameterized[name] = item

triedToAddInvalidObject = (label) ->
  throw 'Tried to add an item with an unresolved base type'

module.exports =
  createLabelForField: createLabelForField
  getParserForType: getFromCollectionByLabel
  addItemToLabelledCollection: addItemToLabelledCollection
  createLabelForType: createLabelForType
  createLabelForTypeclass: createLabelForType
  createLabelForNativeType: createLabelForNativeType
  getFromCollectionByLabel: getFromCollectionByLabel
  createLabelForPattern: createLabelForPattern
