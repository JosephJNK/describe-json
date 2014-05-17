{getFromCollectionByLabel, createLabelForPattern} = require './typeResolver'

module.exports =
  init: (system) ->
    system.init()
    #TODO get rid of this, it's super inefficient
    # I think this is only still around because of some poorly written tests that don't call init themselves

    (pattern, data) ->
      #TODO: Get rid of labels.
      label = createLabelForPattern pattern
      [err, parser] = getFromCollectionByLabel label, system.recognizers
      if err?
        throw "Error: '#{pattern}' could not be resolved to a type"
      else
        parser data
