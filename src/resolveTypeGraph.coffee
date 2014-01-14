{inspect} = require 'util'

resolveTypeclassFields = (typeclasses) ->
  [err, inheritanceTree] = walkInheritanceTree typeclasses
  return [err, null] if err
  [err, resolvedFields] = reduceInheritanceTree inheritanceTree, typeclasses
  return [err, resolvedFields]

dfs = (typeclasses, current, visited) ->
  for parent in typeclasses[current].extends
    return ['Cycle exists', null] unless visited.indexOf typeclass is -1
    newVisited = visited.concat parent
    return [null, dfs typeclasses, parent, newVisited]

walkInheritanceTree = (typeclasses) ->
  resolved = {}
  for typeclass of typeclasses
    [error, typeclassTree] = dfs typeclasses, typeclass, [typeclass]
    return error if error
    resolved[typeclass] = typeclassTree
  return resolved

#run each tree independently, higher elements in inheritance chain at leaves
#if there's a cycle, it will occur in at least one root -> leaf path

getTypeclassFields = (typeclassName, typeclasses) ->
  typeclasses[typeclassName].fields

reduceInheritanceTree = (inheritanceTree, typeclasses) ->
  resolvedInterfaces = {}
  for typeName, typeTree of inheritanceTree
    [err, resolved] = reduceParentTree {typeName: typeTree}
    return [err, null] if err
    resolvedInterfaces[typeName] = resolved
  return [null, resolvedInterfaces]

reduceParentTree = (parentTree, typeclasses) ->
  currentTypeclass = Object.keys(parentTree)[0]

  return getTypeclassFields currentTypeclass, typeclasses if parentTree[currentTypeclass] is {}

  flattenedTrees = {}

  for siblingName, siblingTree of parentTree[currentTypeclass]
    reduced = reduceParentTree {siblingName: siblingTree}
    [err, mergedWithParent]= mergeParent currentTypeclass, reduced, typeclasses
    return [err, null] if err
    flattenedTrees[siblingName] = mergedWithParent

  [err, merged] = mergeSiblings flattenedTrees, currentTypeclass, typeclasses
  return [err, merged]

mergeSiblings = (siblingTrees, typeclassName, typeclasses) ->
  merged = {}
  for typeclassName, fields of siblingTrees
    for fieldName, fieldType of fields
      if merged[fieldName]?
        return ["Error: When resolving fields of #{typeclass}, multiple inherited types define #{fieldName}", null]
      merged[fieldName] = fieldType
  [null, merged]

mergeParent = (typeclass, parentFields, typeclasses) ->
  merged = getTypeclassFields typeclass, typeclasses
  for fieldName, fieldType of parentFields
    if merged[fieldName]?
      return ["Error: typeclass #{typeclass} conflicts with parent's field #{fieldName}", null]
    merged[fieldName] = fieldType
  [null, merged]

addTypeToTypeclass = (typeName, typeclassName, registry) ->
  registry[typeclassName] = [] unless registry[typeclassName]?
  registry[typeclassName].push typeName

module.exports = (types, typeclasses) ->

  resolvedTypes = {}
  resolvedTypeclasses = {}

  [err, resolvedTypeclassFields] = resolveTypeclassFields typeclasses
  return [err, null] if err

  for typeName, typeData of types
    resolvedTypes[typeName] = typeData.fields

    for typeclassName in typeData.typeclasses

      addTypeToTypeclass typeName, typeclassName, resolvedTypeclasses

      for fieldName, fieldType of resolvedTypeclassFields[typeclassName]
        resolvedTypes[typeName][fieldName] = fieldType

  return [null, {
    typefields: resolvedTypes
    typeclassmembers: resolvedTypeclasses
  }]
