generateRecursiveParser = require './generateRecursiveParser'
resolveTypeGraph = require './resolveTypeGraph'
nativeTypeRecognizers = require './nativeTypeRecognizers'
parserRegistry = require './typeRegistry'
{isString, getOnlyKeyForObject} = require './utilities'

# main file for the program, used to register new types and typeclasses
module.exports =
  init: ->
    registeredTypes = {}
    registeredTypeclasses = {}

    #holds parsers
    recognizers = {}

    typeclassMembers = {}

    validateNewType = (newtype) ->
      return 'Type must have a name' unless newtype.name?
      return "'#{newtype.name}' is already registered as a type" if registeredTypes[newtype.name]?
      return "'#{newtype.name}' is already registered as a typeclass" if registeredTypeclasses[newtype.name]?
      return 'Type names must begin with a capital letter' unless newtype.name.match /^[A-Z]/
      null

    validateNewTypeClass = (newtypeclass) ->
      return 'Typeclass must have a name' unless newtypeclass.name?
      return "'#{newtypeclass.name}' is already registered as a typeclass" if registeredTypeclasses[newtypeclass.name]?
      return "'#{newtypeclass.name}' is already registered as a type" if registeredTypes[newtypeclass.name]?
      return 'Typeclass names must begin with a capital letter' unless newtypeclass.name.match /^[A-Z]/
      null

    #builds list of types which belong to each typeclass, as types are added
    addMemberTypes = (typeName, declaredTypeclasses) ->
      for typeclass in declaredTypeclasses
        if isString typeclass
          typeclassName = typeclass
        else
          typeclassName = getOnlyKeyForObject typeclass

        if typeclassMembers[typeclassName]?
          typeclassMembers[typeclassName].push typeName
        else
          typeclassMembers[typeclassName] = [typeName]

    registerType = ({newtype}) ->
      err = validateNewType newtype
      return err if err?
      name = newtype.name
      registeredTypes[name] = newtype
      if newtype.typeclasses?
        addMemberTypes name, newtype.typeclasses
      null

    registerTypeclass = ({newtypeclass}) ->
      err = validateNewTypeClass newtypeclass
      return err if err?
      name = newtypeclass.name
      registeredTypeclasses[name] = newtypeclass
      null

    return {
      register: (input) ->
        return registerType input if input.newtype?
        return registerTypeclass input if input.newtypeclass?
        return 'newtype or newtypeclass keywords must be used'

      init: ->
        registry = parserRegistry.init()

        for nativeTypeName, parser of nativeTypeRecognizers
          registry.addTypeParser nativeTypeName, parser, false

        [err, {typefields, typeclassmembers}] = resolveTypeGraph registeredTypes, registeredTypeclasses
        return err if err
        for typeclassName, typeclassData of registeredTypeclasses
          typeclassParser = generateRecursiveParser 'typeclass', typeclassData, typeclassMembers, registry
          isParametric = typeclassData.typeparameters? and typeclassData.typeparameters.length > 0
          registry.addTypeDeclaration typeclassName, typeclassData
          registry.addTypeParser typeclassName, typeclassParser, isParametric
        for typeName, typeData of registeredTypes
          typeParser = generateRecursiveParser 'type', typeData, typeclassMembers, registry
          isParametric = typeData.typeparameters? and typeData.typeparameters.length > 0
          registry.addTypeclassDeclaration typeclassName, typeclassData
          registry.addTypeParser typeName, typeParser, isParametric

      types: registeredTypes
      typeclasses: registeredTypeclasses
      getDataForType: (type) -> return registeredTypes[type]

      recognizers: recognizers
    }
