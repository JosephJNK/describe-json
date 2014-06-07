generateParser = require './generateRecursiveParser'

module.exports =
  init: ->

    parsers = {}
    fields = {}
    typeDeclarations = {}
    typeclassDeclarations = {}

    nameCorrespondsToTypeclass = (name) ->
      typeclassDeclarations[name]?

    return {
      addTypeDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or typeclassDeclarations[name]?
          throw "Tried to add type declaration for #{name}, but it has already been registered"
        typeDeclarations[name] = declaration

      addTypeclassDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or typeclassDeclarations[name]?
          throw "Tried to add typeclass declaration for #{name}, but it has already been registered"
        typeclassDeclarations[name] = declaration

      addParser: (name, parser) ->
        if parsers[name]?
          throw "Tried to register parser for #{name}, but it has already been registered"
        parsers[name] = parser

      addTypeFields: (typeName, typeFields) ->
        fields[typeName] = typeFields

      getParserByTypeName: (name) ->
        result = parsers[name]
        throw "Type #{name} wasn't registered!" unless result?
        result

      getTypeDeclarationForName: (name) ->
        typeDeclarations[name]

      getTypeclassDeclarationForName: (name) ->
        typeclassDeclarations[name]

      getFieldsForType: (name) ->
        throw "Cannot get field list for typeclass" if nameCorrespondsToTypeclass name
        throw "Type #{name} wasn't registered!" unless fields[name]
        fields[name]

      nameCorrespondsToTypeclass: nameCorrespondsToTypeclass
    }
