generateRecognizer = require './generateRecognizer'

module.exports =
  init: ->
    registeredTypes = {}
    registeredTypeClasses = {}

    recognizers = require './nativeTypeRecognizers'

    validateNewType = (newtype) ->
      return 'Type must have a name' unless newtype.name?
      return "'#{newtype.name}' is already registered as a type" if registeredTypes[newtype.name]?
      return "'#{newtype.name}' is already registered as a typeclass" if registeredTypeClasses[newtype.name]?
      return 'Type names must begin with a capital letter' unless newtype.name.match /^[A-Z]/
      null

    validateNewTypeClass = (newtypeclass) ->
      return 'Typeclass must have a name' unless newtypeclass.name?
      return "'#{newtypeclass.name}' is already registered as a typeclass" if registeredTypeClasses[newtypeclass.name]?
      return "'#{newtypeclass.name}' is already registered as a type" if registeredTypes[newtypeclass.name]?
      return 'Typeclass names must begin with a capital letter' unless newtypeclass.name.match /^[A-Z]/
      null

    registerType = ({newtype}) ->
      err = validateNewType newtype
      return err if err?
      name = newtype.name
      recognizers[name] = generateRecognizer newtype, recognizers
      registeredTypes[name] = newtype
      null

    registerTypeClass = ({newtypeclass}) ->
      err = validateNewTypeClass newtypeclass
      return err if err?
      name = newtypeclass.name
      registeredTypeClasses[name] = newtypeclass
      null

    return {
      register: (input) ->
        return registerType input if input.newtype?
        return registerTypeClass input if input.newtypeclass?
        return 'newtype or newtypeclass keywords must be used'

      types: -> Object.keys registeredTypes
      typeClasses: -> Object.keys registeredTypeClasses
      getDataForType: (type) -> return registeredTypes[type]

      recognizers: recognizers
    }
