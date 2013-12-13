module.exports =
  init: (system) ->
    (type, data) ->
      system.recognizers[type] data
