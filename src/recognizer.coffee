module.exports =
  init: (registry) ->
    (pattern, data) ->
      parser = registry.getParserByTypeName pattern

      if parser is null
        throw "Error: '#{pattern}' could not be resolved to a type"
      else
        parser data
