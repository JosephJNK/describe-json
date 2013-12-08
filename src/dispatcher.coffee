module.exports =
  init: (system) ->
    (input, patterns) ->
      for pattern in patterns
        return pattern.otherwise() if pattern.otherwise()
