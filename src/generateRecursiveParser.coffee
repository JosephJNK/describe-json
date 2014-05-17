{createLabelForField, getParserForType, createLabelForType} = require './typeResolver'
{getOnlyKeyForObject} = require './utilities'
{selectParametersForField} = require './parameterUtilities'

nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (type) -> nativeTypes.indexOf(type.name) isnt -1

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = x[fieldName]
  [fieldName, fieldType]

parseNested = (parsers, fieldLabel, dataToParse, typeParameters) ->
  # TODO: get rid of labels
  [err, parser] = getParserForType fieldLabel, parsers
  throw err if err
  parser dataToParse, typeParameters

# IR = intermediate representation
packIR = (packedObj, fieldName, ir) ->
  packedObj.data[fieldName] = ir.data
  packedObj.typedata.fields[fieldName] = ir.typedata

recordUseOfUnresolvedType = (typeLabel) ->
  throw 'Attempted to parse an unresolved type'

# This is probably poorly named. It takes an array of all the already existing parameters, and the declaration of
# the type that we're making a parser for, and it returns a parser for that field.
# Parsers take data, and any currently applied type parameters as arguments, and return an IR of the parsed data
# This IR is not strictly necessary at the moment, but will be important for things like nested pattern matching, or
# external libraries that interface with this one.
parseFields = (parsers, typeDeclaration) ->
  (dataToParse, typeParameters) ->

    # This is the schema used by the IR. Data and fields are recursive
    # TODO: Data contains the exact input we were given on a match. It should contain only
    # the matched fields (untyped extra fields should be stripped out)
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
      # TODO: Get rid of labels
      typeLabel = createLabelForField fieldObj, thisFieldsParams

      return recordUseOfUnresolvedType typeLabel unless typeLabel.basetypeisresolved

      # TODO: Get rid of labels
      if isNativeType typeLabel
        [err, parser] = getParserForType typeLabel, parsers
        throw err if err?
        ir = parser dataToParse[fieldName]
      else
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
