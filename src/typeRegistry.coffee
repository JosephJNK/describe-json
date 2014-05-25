generateParser = require './generateRecursiveParser'

#TODO: I don't think there needs to be any separation between parameterized and
#unparameterized parsers, since a parser no longer closes over the type paramters
#
#This is causing problems.

module.exports =
  init: ->

    parsers = {}

    typeDeclarations = {}
    typeclassDeclarations = {}

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

      getParserByTypeName: (name) ->
        result = parsers[name]
        throw "Type #{name} wasn't registered!" unless result?
        result

      getTypeDeclarationForName: (name) ->
        typeDeclarations[name]

      getTypeclassDeclarationForName: (name) ->
        typeclassDeclarations[name]

      nameCorrespondsToTypeclass: (name) ->
        typeclassDeclarations[name]?
    }
