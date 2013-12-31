{inspect} = require 'util'
nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (typeName) -> nativeTypes.indexOf typeName isnt -1

getOnlyKeyForObject = (x) -> Object.keys(x)[0] #add validation that there is only one here to registration

irMergeCombinator = (fieldParsers) ->
  (untypedObj) ->
    ir = {}
    for fieldParser in fieldParsers
      fieldIR = fieldParser untypedObj
      return matched: false unless fieldIR.matched
      fieldName = getOnlyKeyForObject fieldIR
      ir[fieldName] = fieldIR[fieldName]
    ir

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = fieldObj[fieldName]
  [fieldName, fieldType]

fieldCombinator = (recognizers, fieldDeclarations) ->
  fieldRecognizers = []

  for fieldObj in fieldDeclarations
    [fieldName, fieldType] = getNameAndTypeFromFieldObject fieldObj

    fieldRecognizer = (untypedData) ->
      fieldExists = untypedData[fieldName]?
      if fieldExists
        return parseField recognizers, fieldType, untypedData[fieldName]
      matched: false

    fieldRecognizers.push fieldRecognizer

  return irMergeCombinator fieldRecognizers

#returns the ir for the field
parseField = (parsers, typeName, fieldData) ->
  return parsers[typeName] fieldData if isNativeType typeName

  if newType.fields?
    fieldsParser = fieldCombinator parsers, newType.fields
    fieldIR = fieldsParser fieldData
#TODO: need to wrap the field with iscontainer and whatnot here

generateParser = (newType, parsers) ->
  #recognizers :: {data -> IR}

  #TODO: need to figure out what to do if we're given an empty type
  if newType.fields?
    fieldsParser = fieldCombinator parsers, newType.fields
    return fieldsParser

module.exports = generateParser
