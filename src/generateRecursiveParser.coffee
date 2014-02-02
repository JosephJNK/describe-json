
{createLabelForField, getParserForType, createLabelForType} = require './typeResolver'
{getOnlyKeyForObject} = require './utilities'
selectParametersForField = require './selectParametersForField'

{inspect} = require 'util'

nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (type) -> nativeTypes.indexOf type.name isnt -1

isTypeParameter = (type, typeParameters) -> typeParameters.indexOf type.name isnt -1

resolveTypeParameter = (parameterName, typeParameters) -> typeParameters[parameterName]

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = x[fieldName]
  [fieldName, fieldType]

parseNested = (parsers, fieldLabels, dataToParse, typeParameters) ->
  [err, parser] = getParserForType fieldLabels, parsers
  throw err if err
  nestedParser = parseFields parsers, parser.fields, typeParameters
  nestedParser dataToParse

packIR = (packedObj, fieldName, ir) ->
  packedObj.data[fieldName] = ir.data
  packedObj.typedata.fields[fieldName] = ir.typedata

recordUseOfUnresolvedType = (typeLabel) ->
  throw 'Attempted to parse an unresolved type'

parseFields = (parsers, typeDeclaration, typeParameters) ->
  (dataToParse) ->

    result =
      matched: true
      data: {}
      typedata:
        iscontainer: true
        type: typeDeclaration.name
        fields: {}

    for fieldName, fieldData of typeDeclaration.fields
      fieldExists = dataToParse[fieldName]?
      return matched: false unless fieldExists

      thisFieldsParams = selectParametersForField fieldData, typeParameters

      typeLabel = createLabelForField fieldData, thisFieldsParams

      return recordUseOfUnresolvedType typeLabel unless typeLabel.basetypeisresolved

      if isNativeType typeLabel
        [err, parser] = getParserForType typeLabel, parsers
        throw err if err?
        ir = parser dataToParse[fieldName]
      else
        ir = parseNested parsers, fieldLabel, dataToParse[fieldName], thisFieldsParams

      return matched: false unless ir.matched
      packIR result, fieldName, ir

    return result

makeTypeclassParser = (parsers, typeclassMembers, types) ->
  (dataToParse) ->
    for typeName in typeclassMembers
      type = types[typeName]
      typeLabel = createLabelForType typeName, type
      [err, parser] = getParserForType typeLabel, parsers
      throw err if err
      ir = parser dataToParse
      return ir if ir.matched
    return matched: false

generateParser = (declarationType, newType, parsers, typeclassMembers, types) ->
  if declarationType is 'type'
    if newType.fields?
      fieldsParser = parseFields parsers, newType, {}
      return fieldsParser

  if declarationType is 'typeclass'
    return makeTypeclassParser parsers, typeclassMembers[newType.name], types

module.exports = generateParser
