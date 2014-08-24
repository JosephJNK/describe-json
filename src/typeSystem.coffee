generateRecursiveParser = require './generateRecursiveParser'
resolveTypeGraph = require './resolveTypeGraph'
nativeTypeRecognizers = require './nativeTypeRecognizers'
parserRegistry = require './typeRegistry'
recognizer = require './recognizer'
validateParameterConstraints = require './typeParameterValidator'

{isString, getOnlyKeyForObject} = require './utilities'

# main file for the program, used to register new types and interfaces
module.exports =
  init: ->
    registeredTypes = {}
    registeredInterfaces = {}

    #holds parsers
    recognizers = {}

    validateNewType = (newtype) ->
      return 'Type must have a name' unless newtype.name?
      return "'#{newtype.name}' is already registered as a type" if registeredTypes[newtype.name]?
      return "'#{newtype.name}' is already registered as a interface" if registeredInterfaces[newtype.name]?
      return 'Type names must begin with a capital letter' unless newtype.name.match /^[A-Z]/
      null

    validateNewInterface = (newinterface) ->
      return 'Interface must have a name' unless newinterface.name?
      return "'#{newinterface.name}' is already registered as a interface" if registeredInterfaces[newinterface.name]?
      return "'#{newinterface.name}' is already registered as a type" if registeredTypes[newinterface.name]?
      return 'Interface names must begin with a capital letter' unless newinterface.name.match /^[A-Z]/
      null

    #builds list of types which belong to each interface, as types are added
    addMemberTypes = (typeName, declaredInterfaces) ->
      for interFace in declaredInterfaces
        if isString interFace
          interfaceName = interFace
        else
          interfaceName = getOnlyKeyForObject interFace

    registerType = ({newtype}) ->
      err = validateNewType newtype
      return err if err?
      name = newtype.name
      registeredTypes[name] = newtype
      if newtype.interfaces?
        addMemberTypes name, newtype.interfaces
      null

    registerInterface = ({newinterface}) ->
      err = validateNewInterface newinterface
      return err if err?
      name = newinterface.name
      registeredInterfaces[name] = newinterface
      null

    recognize = ->
      throw "Cannot use recognize until generate parsers is called"

    return {
      register: (input) ->
        return registerType input if input.newtype?
        return registerInterface input if input.newinterface?
        return 'newtype or newinterface keywords must be used'

      generateParsers: ->
        registry = parserRegistry.init()
        recognize = recognizer.init registry

        for nativeTypeName, parser of nativeTypeRecognizers
          registry.addParser nativeTypeName, parser, false

        [err, {typefields, interfacemembers}] = resolveTypeGraph registeredTypes, registeredInterfaces
        return err if err

        parameterConstraintError = validateParameterConstraints interfacemembers, registeredTypes, registeredInterfaces
        return parameterConstraintError if parameterConstraintError

        for interfaceName, interfaceData of registeredInterfaces
          registry.addInterfaceDeclaration interfaceName, interfaceData
          interfaceParser = generateRecursiveParser 'interface', interfaceData, interfacemembers, registry
          registry.addParser interfaceName, interfaceParser
        for typeName, typeData of registeredTypes
          registry.addTypeFields typeName, typefields[typeName]
          registry.addTypeDeclaration typeName, typeData
          typeParser = generateRecursiveParser 'type', typeData, interfacemembers, registry
          registry.addParser typeName, typeParser
        null

      types: registeredTypes
      interfaces: registeredInterfaces
      getDataForType: (type) -> return registeredTypes[type]

      recognizers: recognizers
      getRecognizer: -> recognize
    }
