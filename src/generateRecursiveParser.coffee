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
  console.log "in packIR: #{inspect packedObj}"

parseFields = (parsers, typeDeclaration) ->
  (dataToParse) ->

    result =
      matched: true
      data: {}
      typedata:
        iscontainer: true
        type: typeDeclaration.name
        fields: {}

    console.log "dataToParse: #{inspect dataToParse}"

    for fieldDeclaration in typeDeclaration.fields
      [fieldName, fieldType] = getNameAndTypeFromFieldObject fieldDeclaration
      console.log "fieldName: #{fieldName}"
      console.log "fieldType: #{fieldType}"
      fieldExists = dataToParse[fieldName]?
      console.log "fieldExists: #{fieldExists}"
      return matched: false unless fieldExists

      if isNativeType fieldType
        console.log "native type"
        ir = parsers[fieldType] dataToParse[fieldName]
      else
        console.log "non-native type"
        ir = parseNested parsers, fieldType, dataToParse[fieldName]

      console.log "ir in parseFields: #{inspect ir}"

      return matched: false unless ir.matched
      packIR result, fieldName, ir

    console.log "after packing: #{inspect result}"
    return result

generateParser = (newType, parsers) ->
  if newType.fields?
    fieldsParser = parseFields parsers, newType
    return fieldsParser

module.exports = generateParser
