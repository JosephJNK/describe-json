{inspect} = require 'util'
utilities = require './utilities'
{resolveAllPossibleParameters} = require './parameterUtilities'

# linerizes type graph
# gives us all of our types, organized by the typeclasses they implement,
# and all of the typeclasses, organized by the types that implement them


######### utility methods ############
extractTypeclassName = (parentNameOrObject) ->
  return parentNameOrObject if utilities.isString parentNameOrObject
  utilities.getOnlyKeyForObject parentNameOrObject

getTypeclassFields = (typeclassName, typeclasses) ->
  typeclasses[typeclassName].fields

######################################

resolveTypeclassFields = (typeclasses) ->
  [err, inheritanceTree] = createInheritanceTree typeclasses
  return [err, null, null] if err
  [err, resolvedFields] = reduceInheritanceTrees inheritanceTree, typeclasses
  return [err, null, null] if err
  parentLists = findTypeclassParents inheritanceTree
  return [null, resolvedFields, parentLists]

# This flattens the inheritance tree into an array. It returns an object
# Key: the name of a typeclass/interface
# Value: an array of the interfaces that this interface extends
findTypeclassParents = (inheritanceTree) ->
  parentLists = {}
  for typeName, typeTree of inheritanceTree
    parentLists[typeName] = utilities.getAllNonemptyNodesInTree typeTree
  parentLists

# depth first search, to build up inheritance tree and make sure that there's not a cycle in interface extensions
# i.e. If A extends B, B cannot extend A
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

#This makes a bunch of trees in an object
#The object contains typeclass/interface names as keys, and their inheritance trees as values
#The trees have the typclass/interface as a key, whose value is another object.
#   This object has all of the interfaces which this interface extends as keys. Their values are the inheritance trees of these interfaces
#   Yes, this is a lot of duplication, but it's easier than trying to avoid the duplication. This only runs once at startup so we don't care about efficiency.
createInheritanceTree = (typeclasses) ->
  resolved = {}
  for typeclassName, typeclassDefinition of typeclasses
    [error, typeclassTree] = dfs typeclasses, typeclassName, [typeclassName]
    return [error, null] if error
    resolved[typeclassName] = typeclassTree
  return [null, resolved]

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
    resolvedTypeclassParams = resolveAllPossibleParameters parametersToExtendedTypeclass, typeParameters

    [err, extendedTypeclassFields] = getFieldsFromInheritanceTree extendedTypeclassName, extendedTypeclassInheritanceTree, typeclasses, resolvedTypeclassParams
    return [err, null] if err

    flattenedSiblingTrees[extendedTypeclassName] = extendedTypeclassFields

  [err, inheritedFields] = mergeSiblingFields flattenedSiblingTrees, typeclassName, typeclasses

  [err, myResolvedFields] = mergeFieldsWithParent typeclassName, myTypeclassFields, inheritedFields

  return [err, myResolvedFields]

mergeSiblingFields = (siblingFieldsObject) ->
  merged = {}
  for typeclassName, fields of siblingFieldsObject
    for fieldName, fieldType of fields
      # TODO: this should not trigger an error if the types are identical
      #         It would be neat if one was a subset of the other (the same type with type constraints, or a more specific
      #         typeclass), if we set this to the most specific type possible
      if merged[fieldName]?
        return ["Error: When resolving fields of #{typeclass}, multiple inherited types define #{fieldName}", null]
      merged[fieldName] = fieldType
  [null, merged]

mergeFieldsWithParent = (typeclassName, childFields, parentFields) ->
  merged = utilities.cloneFlatObject childFields

  for fieldName, fieldType of parentFields
    # TODO: this should not trigger an error if the types are identical
    #         It would be neat if one was a subset of the other (the same type with type constraints, or a more specific
    #         typeclass), if we set this to the most specific type possible
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
        mixedInFields = resolveAllPossibleParameters resolvedTypeclassFields[typeclassName], parametersForTypeclass

        for fieldName, fieldType of mixedInFields
          resolvedTypes[typeName] = {} unless resolvedTypes[typeName]?
          resolvedTypes[typeName][fieldName] = fieldType

  # typefields: keys are the type names, values are the fields that that type has, including mixins
  #   I think this does something with type parameters, maybe?
  # typeclassmembers: keys are typeclass names, values are arrays of type names, which belong to that typeclass
  return [null, {
    typefields: resolvedTypes
    typeclassmembers: resolvedTypeclasses
  }]
