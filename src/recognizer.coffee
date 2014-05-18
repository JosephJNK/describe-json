module.exports =
  init: (system) ->
    (pattern, data) ->
      registry = system.registry
      parser = registry.getParserByTypeName pattern

      if parser is null
        throw "Error: '#{pattern}' could not be resolved to a type"
      else
        parser data
