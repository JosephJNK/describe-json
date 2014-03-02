{inspect} = require 'util'
utilities = require './utilities'
{resolveAllPossibleParameters} = require './parameterUtilities'

resolveTypeclassFields = (typeclasses) ->
  [err, inheritanceTree] = createInheritanceTree typeclasses
  return [err, null, null] if err
  [err, resolvedFields] = reduceInheritanceTrees inheritanceTree, typeclasses
  return [err, null, null] if err
  parentLists = findTypeclassParents inheritanceTree
  return [null, resolvedFields, parentLists]

findTypeclassParents = (inheritanceTree) ->
  parentLists = {}
  for typeName, typeTree of inheritanceTree
    parentLists[typeName] = utilities.getAllNonemptyNodesInTree typeTree
  parentLists

dfs = (typeclasses, current, visited) ->
  currentTypeclassData = typeclasses[current]
  return [null, {}] unless currentTypeclassData?
  parentTypes = currentTypeclassData.extends
  return [null, {}] unless parentTypes?

  elements = {}

  for parent in parentTypes
    parentName = extractTypeclassName parent
    return ['Cycle exists', null] unless visited.indexOf parentName is -1
    newVisited = visited.concat parentName
    [err, parentTree] = dfs typeclasses, parentName, newVisited
    return [err, null] if err
    elements[parentName] = parentTree

  [null, elements]

extractTypeclassName = (parentNameOrObject) ->
  return parentNameOrObject if utilities.isString parentNameOrObject
  utilities.getOnlyKeyForObject parentNameOrObject

createInheritanceTree = (typeclasses) ->
  resolved = {}
  for typeclassName, typeclassDefinition of typeclasses
    [error, typeclassTree] = dfs typeclasses, typeclassName, [typeclassName]
    return [error, null] if error
    resolved[typeclassName] = typeclassTree
  return [null, resolved]

getTypeclassFields = (typeclassName, typeclasses) ->
  typeclasses[typeclassName].fields

reduceInheritanceTrees = (inheritanceTree, typeclasses) ->
  resolvedInterfaces = {}
  for typeName, typeParentTree of inheritanceTree
    [err, resolved] = getFieldsFromInheritanceTree typeName, typeParentTree, typeclasses, {}
    return [err, null] if err
    resolvedInterfaces[typeName] = resolved
  return [null, resolvedInterfaces]

getParametersToExtendedTypeclass = (typeclassName, extendedTypeclassName, typeclasses) ->
  extensionDeclarations = typeclasses[typeclassName].extends
  for extension in extensionDeclarations
    if utilities.isObject(extension) and utilities.getOnlyKeyForObject(extension) is extendedTypeclassName
      return utilities.getOnlyValueForObject extension
  return {}

getParametersToTypeclassForType = (typeDeclaration, typeclassName) ->
  #TODO remove duplication with above
  typeclassDeclarations = typeDeclaration.typeclasses
  for typeclass in typeclassDeclarations
    if utilities.isObject(typeclass) and utilities.getOnlyKeyForObject(typeclass) is typeclassName
      return utilities.getOnlyValueForObject typeclass
  return {}

getFieldsFromInheritanceTree = (typeclassName, inheritanceTree, typeclasses, typeParameters) ->
  myUnresolvedFields = getTypeclassFields typeclassName, typeclasses
  myTypeclassFields = resolveAllPossibleParameters myUnresolvedFields, typeParameters
  return [null, myTypeclassFields] if inheritanceTree is {}

  flattenedSiblingTrees = {}

  for extendedTypeclassName, extendedTypeclassInheritanceTree of inheritanceTree
    parametersToExtendedTypeclass = getParametersToExtendedTypeclass typeclassName, extendedTypeclassName, typeclasses
    console.log 'parametersToExtendedTypeclass: ', inspect parametersToExtendedTypeclass
    parametersToExtendedTypeclass = resolveAllPossibleParameters parametersToExtendedTypeclass, typeParameters

    [err, extendedTypeclassFields] = getFieldsFromInheritanceTree extendedTypeclassName, extendedTypeclassInheritanceTree, typeclasses, parametersToExtendedTypeclass
    return [err, null] if err

    flattenedSiblingTrees[extendedTypeclassName] = extendedTypeclassFields

  [err, inheritedFields] = mergeSiblingFields flattenedSiblingTrees, typeclassName, typeclasses

  [err, myResolvedFields] = mergeFieldsWithParent typeclassName, myTypeclassFields, inheritedFields

  return [err, myResolvedFields]

mergeSiblingFields = (siblingFieldsObject) ->
  merged = {}
  for typeclassName, fields of siblingFieldsObject
    for fieldName, fieldType of fields
      if merged[fieldName]?
        return ["Error: When resolving fields of #{typeclass}, multiple inherited types define #{fieldName}", null]
      merged[fieldName] = fieldType
  [null, merged]

mergeFieldsWithParent = (typeclassName, childFields, parentFields) ->
  merged = utilities.cloneFlatObject childFields

  for fieldName, fieldType of parentFields
    if merged[fieldName]?
      return ["Error: typeclass #{typeclassName} conflicts with parent's field #{fieldName}", null]
    merged[fieldName] = fieldType
  [null, merged]

addTypeToTypeclass = (typeName, typeclassName, registry, typeclassParentLists) ->
  registry[typeclassName] = [] unless registry[typeclassName]?
  registry[typeclassName].push typeName if registry[typeclassName].indexOf typeName is -1
  if typeclassParentLists[typeclassName]?
    for typeclass in typeclassParentLists[typeclassName]
      registry[typeclass] = [] unless registry[typeclass]?
      registry[typeclass].push typeName if registry[typeclassName].indexOf typeName is -1

module.exports = (types, typeclasses) ->
  resolvedTypes = {}
  resolvedTypeclasses = {}

  [err, resolvedTypeclassFields, typeclassParentLists] = resolveTypeclassFields typeclasses
  return [err, null] if err

  for typeName, typeData of types
    resolvedTypes[typeName] = typeData.fields

    if typeData.typeclasses
      for typeclass in typeData.typeclasses

        typeclassName = if utilities.isString(typeclass) then typeclass else utilities.getOnlyKeyForObject typeclass

        addTypeToTypeclass typeName, typeclassName, resolvedTypeclasses, typeclassParentLists

        parametersForTypeclass = getParametersToTypeclassForType typeData, typeclassName

        console.log 'parametersForTypeclass:' + inspect parametersForTypeclass, depth:null
        console.log "resolvedTypeclassFields[#{typeclassName}]:" + inspect resolvedTypeclassFields[typeclassName], depth:null

        mixedInFields = resolveAllPossibleParameters resolvedTypeclassFields[typeclassName], parametersForTypeclass

        console.log 'mixedInFields:' + inspect mixedInFields, depth:null
        console.log '\n\n'

        for fieldName, fieldType of mixedInFields
          console.log 'fieldType: ' + inspect fieldType
          resolvedTypes[typeName] = {} unless resolvedTypes[typeName]?
          resolvedTypes[typeName][fieldName] = fieldType

  return [null, {
    typefields: resolvedTypes
    typeclassmembers: resolvedTypeclasses
  }]
