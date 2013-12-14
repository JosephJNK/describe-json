{inspect} = require 'util'
module.exports =
  init: (system) ->
    (type, data) ->
      if system.recognizers[type]?
        system.recognizers[type] data
      else
        throw "Error: '#{type}' is not a registered type"
