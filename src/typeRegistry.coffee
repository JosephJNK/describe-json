generateParser = require './generateRecursiveParser'

module.exports =
  init: ->

    parsers = {}
    fields = {}
    typeDeclarations = {}
    interfaceDeclarations = {}

    nameCorrespondsToInterface = (name) ->
      interfaceDeclarations[name]?

    return {
      addTypeDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or interfaceDeclarations[name]?
          throw "Tried to add type declaration for #{name}, but it has already been registered"
        typeDeclarations[name] = declaration

      addInterfaceDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or interfaceDeclarations[name]?
          throw "Tried to add interface declaration for #{name}, but it has already been registered"
        interfaceDeclarations[name] = declaration

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

      getInterfaceDeclarationForName: (name) ->
        interfaceDeclarations[name]

      getFieldsForType: (name) ->
        throw "Cannot get field list for interface" if nameCorrespondsToInterface name
        throw "Type #{name} wasn't registered!" unless fields[name]
        fields[name]

      nameCorrespondsToInterface: nameCorrespondsToInterface
    }
