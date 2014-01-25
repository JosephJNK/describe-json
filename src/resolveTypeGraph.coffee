{inspect} = require 'util'
utilities = require './utilities'

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
    return ['Cycle exists', null] unless visited.indexOf parent is -1
    newVisited = visited.concat parent
    [err, parentTree] = dfs typeclasses, parent, newVisited
    return [err, null] if err
    elements[parent] = parentTree

  [null, elements]

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
    [err, resolved] = getFieldsFromInheritanceTree typeName, typeParentTree, typeclasses
    return [err, null] if err
    resolvedInterfaces[typeName] = resolved
  return [null, resolvedInterfaces]

getFieldsFromInheritanceTree = (typeclassName, inheritanceTree, typeclasses) ->
  myTypeclassFields = getTypeclassFields typeclassName, typeclasses
  return [null, myTypeclassFields] if inheritanceTree is {}

  flattenedSiblingTrees = {}

  for siblingName, siblingInheritanceTree of inheritanceTree
    [err, siblingFields] = getFieldsFromInheritanceTree siblingName, siblingInheritanceTree, typeclasses
    return [err, null] if err
    flattenedSiblingTrees[siblingName] = siblingFields

  [err, mergedSiblingFields] = mergeSiblingFields flattenedSiblingTrees, typeclassName, typeclasses

  [err, mergedFields] = mergeFieldsWithParent typeclassName, myTypeclassFields, mergedSiblingFields

  return [err, mergedFields]

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
      for typeclassName in typeData.typeclasses

        addTypeToTypeclass typeName, typeclassName, resolvedTypeclasses, typeclassParentLists

        if resolvedTypeclassFields[typeclassName]
          for fieldName, fieldType of resolvedTypeclassFields[typeclassName]
            resolvedTypes[typeName][fieldName] = fieldType

  return [null, {
    typefields: resolvedTypes
    typeclassmembers: resolvedTypeclasses
  }]
