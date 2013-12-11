{inspect} = require 'util'

matchTypeFields = () ->

module.exports =
  init: (system) ->
    (input, patterns) ->
      for pattern in patterns
        keys = Object.keys pattern
        throw 'Too many fields in pattern' if keys.length > 1
        typeName = keys[0]

        return pattern.otherwise() if typeName is 'otherwise'

        typeData = system.getDataForType typeName
        throw "Error: #{typeName} is not a valid type" unless typeData?
        return pattern[typeName](input) if match input, typeName

      throw 'Error: no pattern matched'
