
{createLabelForField, getParserForType, createLabelForType} = require './typeResolver'
{getOnlyKeyForObject} = require './utilities'
{selectParametersForField} = require './parameterUtilities'

{inspect} = require 'util'

nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (type) -> nativeTypes.indexOf(type.name) isnt -1

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = x[fieldName]
  [fieldName, fieldType]

parseNested = (parsers, fieldLabel, dataToParse, typeParameters) ->
  [err, parser] = getParserForType fieldLabel, parsers
  throw err if err
  parser dataToParse, typeParameters

packIR = (packedObj, fieldName, ir) ->
  packedObj.data[fieldName] = ir.data
  packedObj.typedata.fields[fieldName] = ir.typedata

recordUseOfUnresolvedType = (typeLabel) ->
  throw 'Attempted to parse an unresolved type'

parseFields = (parsers, typeDeclaration) ->
  (dataToParse, typeParameters) ->

    console.log "typeDeclaration: #{inspect typeDeclaration, depth: null}"
    console.log "typeParameters: #{inspect typeParameters, depth: null}"

    result =
      matched: true
      data: {}
      typedata:
        typeparameters: if typeParameters? then typeParameters else {}
        iscontainer: true
        type: typeDeclaration.name
        fields: {}

    for fieldName, fieldData of typeDeclaration.fields
      fieldExists = dataToParse[fieldName]?
      return matched: false unless fieldExists

      [err, thisFieldsParams] = selectParametersForField fieldData, typeParameters

      fieldObj = {}
      fieldObj[fieldName] = fieldData
      typeLabel = createLabelForField fieldObj, thisFieldsParams

      console.log "fieldName: #{fieldName}"
      console.log "thisFieldsParams: #{inspect thisFieldsParams, depth: null}"
      console.log "typelabel: #{inspect typeLabel, depth: null}"

      return recordUseOfUnresolvedType typeLabel unless typeLabel.basetypeisresolved

      if isNativeType typeLabel
        [err, parser] = getParserForType typeLabel, parsers
        throw err if err?
        console.log "parsing #{typeLabel.name}"
        ir = parser dataToParse[fieldName]
      else
        console.log 'going to parseNested'
        ir = parseNested parsers, typeLabel, dataToParse[fieldName], thisFieldsParams


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
      fieldsParser = parseFields parsers, newType
      return fieldsParser

  if declarationType is 'typeclass'
    return makeTypeclassParser parsers, typeclassMembers[newType.name], types

module.exports = generateParser
