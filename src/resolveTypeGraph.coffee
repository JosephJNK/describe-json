{inspect} = require 'util'
getInheritedFieldsForTypeclass = (typeclassName, typeclasses) ->
  typeclasses[typeclassName].fields

addTypeToTypeclass = (typeName, typeclassName, registry) ->
  registry[typeclassName] = [] unless registry[typeclassName]?
  registry[typeclassName].push typeName

module.exports = (types, typeclasses) ->

  resolvedTypes = {}
  resolvedTypeclasses = {}

  for typeName, typeData of types
    resolvedTypes[typeName] = typeData.fields

    for typeclassName in typeData.typeclasses

      addTypeToTypeclass typeName, typeclassName, resolvedTypeclasses

      for field in getInheritedFieldsForTypeclass typeclassName, typeclasses
        console.log "field: #{inspect field}"
        resolvedTypes[typeName][fieldName] = fieldType

  return {
    typefields: resolvedTypes
    typeclassmembers: resolvedTypeclasses
  }
