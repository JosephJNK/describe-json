{inspect} = require 'util'

nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (typeName) -> nativeTypes.indexOf typeName isnt -1

getOnlyKeyForObject = (x) -> Object.keys(x)[0] #add validation that there is only one here to registration

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = x[fieldName]
  [fieldName, fieldType]

parseNested = (parsers, fieldType, dataToParse) ->
  nestedParser = parseFields parsers, parsers[fieldType].fields
  nestedParser dataToParse

packIR = (packedObj, fieldName, ir) ->
  packedObj.data[fieldName] = ir.data
  packedObj.typedata.fields[fieldName] = ir.typedata

parseFields = (parsers, typeDeclaration) ->
  (dataToParse) ->

    result =
      matched: true
      data: {}
      typedata:
        iscontainer: true
        type: typeDeclaration.name
        fields: {}

    #this shouldn't use typeDeclaration.fields
    #the fields should be loaded lazily and mix in typeclasses
    for fieldName, fieldType of typeDeclaration.fields
      fieldExists = dataToParse[fieldName]?
      return matched: false unless fieldExists

      if isNativeType fieldType
        ir = parsers[fieldType] dataToParse[fieldName]
      else
        ir = parseNested parsers, fieldType, dataToParse[fieldName]

      return matched: false unless ir.matched
      packIR result, fieldName, ir

    return result

makeTypeclassParser = (parsers, typeclassMembers) ->
  (dataToParse) ->
    for type in typeclassMembers
      ir = parsers[type] dataToParse
      return ir if ir.matched
    return matched: false

generateParser = (declarationType, newType, parsers, typeclassMembers) ->
  if declarationType is 'type'
    if newType.fields?
      fieldsParser = parseFields parsers, newType
      return fieldsParser

  if declarationType is 'typeclass'
    return makeTypeclassParser parsers, typeclassMembers[newType.name]

module.exports = generateParser
