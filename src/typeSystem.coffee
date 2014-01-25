generateRecursiveParser = require './generateRecursiveParser'
resolveTypeGraph = require './resolveTypeGraph'

module.exports =
  init: ->
    registeredTypes = {}
    registeredTypeclasses = {}

    typeclassMembers = {}

    recognizers = require './nativeTypeRecognizers'

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

    addMemberTypes = (typeName, typeclassNames) ->
      for typeclassName in typeclassNames
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
        [err, {typefields, typeclassmembers}] = resolveTypeGraph registeredTypes, registeredTypeclasses
        return err if err
        for typeclassName, typeclassData of registeredTypeclasses
          recognizers[typeclassName] = generateRecursiveParser 'typeclass', typeclassData, recognizers, typeclassMembers
        for typeName, typeData of registeredTypes
          recognizers[typeName] = generateRecursiveParser 'type', typeData, recognizers, typeclassMembers

      types: registeredTypes
      typeclasses: registeredTypeclasses
      getDataForType: (type) -> return registeredTypes[type]

      recognizers: recognizers
    }
