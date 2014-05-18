generateParser = require './generateRecursiveParser'

module.exports =
  init: ->

    unparameterizedTypes = {}
    parameterizedTypes = []

    typeDeclarations = {}
    typeclassDeclarations = {}

    return {
      addTypeDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or typeclassDeclarations[name]?
          throw "Tried to add declaration for #{name}, but it has already been registered"
        typeDeclarations[name] = declaration

      addTypeclassDeclaration: (name, declaration) ->
        if typeDeclarations[name]? or typeclassDeclarations[name]?
          throw "Tried to add declaration for #{name}, but it has already been registered"
        typeclassDeclarations[name] = declaration

      addTypeParser: (name, parser, hasParameters) ->
        if unparameterizedTypes[name]? or parameterizedTypes[name]?
          throw "Tried to register #{name} as a type, but it has already been registered"
        if hasParameters
          parameterizedTypes.push name
        else
          unparameterizedTypes[name] = parser

      getParserByTypeName: (name) ->
        if parameterizedTypes.indexOf(name) isnt -1
          null
        else
          result = unparameterizedTypes[name]
          throw "Type #{name} wasn't registered!" unless result?
          result

      getTypeDeclarationForName: (name) ->
        typeDeclarations[name]

      getTypeclassDeclarationForName: (name) ->
        typeclassDeclarations[name]

      nameCorrespondsToTypeclass: (name) ->
        typeclassDeclarations[name]?
    }
