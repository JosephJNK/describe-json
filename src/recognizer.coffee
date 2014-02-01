{getFromCollectionByLabel, createLabelForPattern} = require './typeResolver'

module.exports =
  init: (system) ->
    system.init() #TODO get rid of this, it's super inefficient

    (pattern, data) ->
      label = createLabelForPattern pattern
      [err, parser] = getFromCollectionByLabel label, system.recognizers
      if err?
        throw "Error: '#{pattern}' could not be resolved to a type"
      else
        parser data
