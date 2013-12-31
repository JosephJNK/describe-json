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
  packedObj.data[fieldName] = ir.data[fieldName]
  packedObj.typedata[fieldName] = ir.typedata[fieldName]

parseFields = (parsers, fieldDeclarations) ->
  (dataToParse) ->

    result =
      matched: true
      data: {}
      typedata: {}

    console.log "fieldDeclarations: #{inspect fieldDeclarations}"
    console.log "dataToParse: #{inspect dataToParse}"

    for fieldDeclaration in fieldDeclarations
      [fieldName, fieldType] = getNameAndTypeFromFieldObject fieldDeclaration
      console.log "fieldName: #{fieldName}"
      console.log "fieldType: #{fieldType}"
      fieldExists = dataToParse[fieldName]?
      return matched: false unless fieldExists

      if isNativeType fieldType
        ir = parsers[fieldType] dataToParse[fieldName]
      else
        ir = parseNested parsers, fieldType, dataToParse[fieldName]

      console.log "ir: #{inspect ir}"

      return matched: false unless ir.matched
      packIR result, fieldName, ir

    console.log inspect result
    return result

generateParser = (newType, parsers) ->
  if newType.fields?
    fieldsParser = parseFields parsers, newType.fields
    return fieldsParser

module.exports = generateParser
