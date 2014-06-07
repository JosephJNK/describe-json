{inspect} = require 'util'
utilities = require './utilities'
{resolveAllPossibleParameters} = require './parameterUtilities'

# linerizes type graph
# gives us all of our types, organized by the interfaces they implement,
# and all of the interfaces, organized by the types that implement them

extractInterfaceName = (parentNameOrObject) ->
  return parentNameOrObject if utilities.isString parentNameOrObject
  utilities.getOnlyKeyForObject parentNameOrObject

getInterfaceFields = (interfaceName, interfaces) ->
  interfaces[interfaceName].fields

resolveInterfaceFields = (interfaces) ->
  [err, inheritanceTree] = createInheritanceTree interfaces
  return [err, null, null] if err
  [err, resolvedFields] = reduceInheritanceTrees inheritanceTree, interfaces
  return [err, null, null] if err
  parentLists = findInterfaceParents inheritanceTree
  return [null, resolvedFields, parentLists]

# This flattens the inheritance tree into an array. It returns an object
# Key: the name of a interface/interface
# Value: an array of the interfaces that this interface extends
findInterfaceParents = (inheritanceTree) ->
  parentLists = {}
  for typeName, typeTree of inheritanceTree
    parentLists[typeName] = utilities.getAllNonemptyNodesInTree typeTree
  parentLists

# depth first search, to build up inheritance tree and make sure that there's not a cycle in interface extensions
# i.e. If A extends B, B cannot extend A
dfs = (interfaces, current, visited) ->
  currentInterfaceData = interfaces[current]
  return [null, {}] unless currentInterfaceData?
  parentTypes = currentInterfaceData.extends
  return [null, {}] unless parentTypes?

  elements = {}

  for parent in parentTypes
    parentName = extractInterfaceName parent
    return ['Cycle exists', null] unless visited.indexOf parentName is -1
    newVisited = visited.concat parentName
    [err, parentTree] = dfs interfaces, parentName, newVisited
    return [err, null] if err
    elements[parentName] = parentTree

  [null, elements]

#This makes a bunch of trees in an object
#The object contains interface/interface names as keys, and their inheritance trees as values
#The trees have the typclass/interface as a key, whose value is another object.
#   This object has all of the interfaces which this interface extends as keys. Their values are the inheritance trees of these interfaces
#   Yes, this is a lot of duplication, but it's easier than trying to avoid the duplication. This only runs once at startup so we don't care about efficiency.
createInheritanceTree = (interfaces) ->
  resolved = {}
  for interfaceName, interfaceDefinition of interfaces
    [error, interfaceTree] = dfs interfaces, interfaceName, [interfaceName]
    return [error, null] if error
    resolved[interfaceName] = interfaceTree
  return [null, resolved]

reduceInheritanceTrees = (inheritanceTree, interfaces) ->
  resolvedInterfaces = {}
  for typeName, typeParentTree of inheritanceTree
    [err, resolved] = getFieldsFromInheritanceTree typeName, typeParentTree, interfaces, {}
    return [err, null] if err
    resolvedInterfaces[typeName] = resolved
  return [null, resolvedInterfaces]

getParametersToExtendedInterface = (interfaceName, extendedInterfaceName, interfaces) ->
  extensionDeclarations = interfaces[interfaceName].extends
  for extension in extensionDeclarations
    if utilities.isObject(extension) and utilities.getOnlyKeyForObject(extension) is extendedInterfaceName
      return utilities.getOnlyValueForObject extension
  return {}

getParametersToInterfaceForType = (typeDeclaration, interfaceName) ->
  interfaceDeclarations = typeDeclaration.interfaces
  for interFace in interfaceDeclarations
    if utilities.isObject(interFace) and utilities.getOnlyKeyForObject(interFace) is interfaceName
      return utilities.getOnlyValueForObject interFace
  return {}

getFieldsFromInheritanceTree = (interfaceName, inheritanceTree, interfaces, typeParameters) ->
  myUnresolvedFields = getInterfaceFields interfaceName, interfaces
  myInterfaceFields = resolveAllPossibleParameters myUnresolvedFields, typeParameters
  return [null, myInterfaceFields] if inheritanceTree is {}

  flattenedSiblingTrees = {}

  for extendedInterfaceName, extendedInterfaceInheritanceTree of inheritanceTree
    parametersToExtendedInterface = getParametersToExtendedInterface interfaceName, extendedInterfaceName, interfaces
    resolvedInterfaceParams = resolveAllPossibleParameters parametersToExtendedInterface, typeParameters

    [err, extendedInterfaceFields] = getFieldsFromInheritanceTree extendedInterfaceName, extendedInterfaceInheritanceTree, interfaces, resolvedInterfaceParams
    return [err, null] if err

    flattenedSiblingTrees[extendedInterfaceName] = extendedInterfaceFields

  [err, inheritedFields] = mergeSiblingFields flattenedSiblingTrees, interfaceName, interfaces

  [err, myResolvedFields] = mergeFieldsWithParent interfaceName, myInterfaceFields, inheritedFields

  return [err, myResolvedFields]

mergeSiblingFields = (siblingFieldsObject) ->
  merged = {}
  for interfaceName, fields of siblingFieldsObject
    for fieldName, fieldType of fields
      # TODO: this should not trigger an error if the types are identical
      #         It would be neat if one was a subset of the other (the same type with type constraints, or a more specific
      #         interface), if we set this to the most specific type possible
      if merged[fieldName]?
        return ["Error: When resolving fields of #{interfaceName}, multiple inherited types define #{fieldName}", null]
      merged[fieldName] = fieldType
  [null, merged]

mergeFieldsWithParent = (interfaceName, childFields, parentFields) ->
  merged = utilities.cloneFlatObject childFields

  for fieldName, fieldType of parentFields
    # TODO: this should not trigger an error if the types are identical
    #         It would be neat if one was a subset of the other (the same type with type constraints, or a more specific
    #         interface), if we set this to the most specific type possible
    if merged[fieldName]?
      return ["Error: interface #{interfaceName} conflicts with parent's field #{fieldName}", null]
    merged[fieldName] = fieldType
  [null, merged]

addTypeToInterface = (typeName, interfaceName, registry, interfaceParentLists) ->
  registry[interfaceName] = [] unless registry[interfaceName]?
  registry[interfaceName].push typeName if registry[interfaceName].indexOf typeName is -1
  if interfaceParentLists[interfaceName]?
    for interFace in interfaceParentLists[interfaceName]
      registry[interFace] = [] unless registry[interFace]?
      registry[interFace].push typeName if registry[interfaceName].indexOf typeName is -1

module.exports = (types, interfaces) ->
  resolvedTypes = {}
  resolvedInterfaces = {}

  [err, resolvedInterfaceFields, interfaceParentLists] = resolveInterfaceFields interfaces
  return [err, null] if err

  for typeName, typeData of types
    resolvedTypes[typeName] = typeData.fields

    if typeData.interfaces
      for interFace in typeData.interfaces

        interfaceName = if utilities.isString(interFace) then interFace else utilities.getOnlyKeyForObject interFace

        addTypeToInterface typeName, interfaceName, resolvedInterfaces, interfaceParentLists

        parametersForInterface = getParametersToInterfaceForType typeData, interfaceName
        mixedInFields = resolveAllPossibleParameters resolvedInterfaceFields[interfaceName], parametersForInterface

        for fieldName, fieldType of mixedInFields
          resolvedTypes[typeName] = {} unless resolvedTypes[typeName]?
          resolvedTypes[typeName][fieldName] = fieldType

  # typefields: keys are the type names, values are the fields that that type has, including mixins
  #   I think this does something with type parameters, maybe?
  # interfacemembers: keys are interface names, values are arrays of type names, which belong to that interface
  return [null, {
    typefields: resolvedTypes
    interfacemembers: resolvedInterfaces
  }]
