{isString, getOnlyKeyForObject, beginsWithUpperCase} = require './utilities'
{selectParametersForField} = require './parameterUtilities'

nativeTypes = Object.keys require './nativeTypeRecognizers'

isNativeType = (typeName) -> nativeTypes.indexOf(typeName) isnt -1

#TODO: unit test this, probably move it to a utility
getTypeNameForField = (fieldData, parameters) ->
  if isString(fieldData) and beginsWithUpperCase fieldData
    return fieldData
  if isString(fieldData) and not beginsWithUpperCase fieldData
    return parameters[fieldData]

  name = getOnlyKeyForObject fieldData
  if beginsWithUpperCase name
    return name
  else
    return parameters[name]

getNameAndTypeFromFieldObject = (x) ->
  fieldName = getOnlyKeyForObject x
  fieldType = x[fieldName]
  [fieldName, fieldType]

parseNested = (fieldTypeName, dataToParse, typeParameters, typeRegistry, interfaceMembers) ->
  parser = typeRegistry.getParserByTypeName fieldTypeName
  if parser is null
    if typeRegistry.nameCorrespondsToInterface fieldTypeName
      membersOfThisInterface = interfaceMembers[fieldTypeName]
      parser = makeInterfaceParser membersOfThisInterface, typeRegistry
    else
      fields = typeRegistry.getFieldsForType fieldTypeName
      parser = parseFields fieldTypeName, fields, typeRegistry, interfaceMembers
  parser dataToParse, typeParameters

packIR = (packedObj, fieldName, ir) ->
  packedObj.data[fieldName] = ir.data
  packedObj.typedata.fields[fieldName] = ir.typedata

recordUseOfUnresolvedType = (typeName) ->
  throw 'Attempted to parse an unresolved type'

# This is probably poorly named. It takes an array of all the already existing parameters, and the declaration of
# the type that we're making a parser for, and it returns a parser for that field.
# Parsers take data, and any currently applied type parameters as arguments, and return an IR of the parsed data
# This IR is not strictly necessary at the moment, but will be important for things like nested pattern matching, or
# external libraries that interface with this one.
parseFields = (typeName, typeFields, typeRegistry, interfaceMembers) ->
  (dataToParse, typeParameters) ->

    # This is the schema used by the IR. Data and fields are recursive
    # TODO: Data contains the exact input we were given on a match. It should contain only
    # the matched fields (untyped extra fields should be stripped out)
    #
    # Actually, we should probably take an argument specifying whether we should extract or reject extra fields
    result =
      matched: true
      data: {}
      typedata:
        typeparameters: if typeParameters? then typeParameters else {}
        iscontainer: true
        type: typeName
        fields: {}

    for fieldName, fieldData of typeFields
      fieldExists = dataToParse[fieldName]?
      return matched: false unless fieldExists

      [err, thisFieldsParams] = selectParametersForField fieldData, typeParameters

      fieldTypeName = getTypeNameForField fieldData, typeParameters

      return recordUseOfUnresolvedType fieldTypeName unless fieldTypeName

      if isNativeType fieldTypeName
        parser = typeRegistry.getParserByTypeName fieldTypeName
        ir = parser dataToParse[fieldName]
      else
        ir = parseNested fieldTypeName, dataToParse[fieldName], thisFieldsParams, typeRegistry, interfaceMembers

      return matched: false unless ir.matched
      packIR result, fieldName, ir

    return result

makeInterfaceParser = (membersOfThisInterface, typeRegistry) ->
  (dataToParse, typeParameters) ->
    for typeName in membersOfThisInterface
      parser = typeRegistry.getParserByTypeName typeName
      ir = parser dataToParse, typeParameters
      return ir if ir.matched
    return matched: false

generateParser = (declarationType, typeDeclaration, interfaceMembers, typeRegistry) ->
  if declarationType is 'type'
    typeName = typeDeclaration.name
    typeFields = typeRegistry.getFieldsForType typeName
    fieldsParser = parseFields typeName, typeFields, typeRegistry, interfaceMembers
    return fieldsParser

  if declarationType is 'interface'
    return makeInterfaceParser interfaceMembers[typeDeclaration.name], typeRegistry

module.exports = generateParser
