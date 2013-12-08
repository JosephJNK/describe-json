match = (input, pattern) -> null

module.exports =
  init: (system) ->
    (input, patterns) ->
      for pattern in patterns
        return pattern.otherwise() if pattern.otherwise
        type = match input, pattern
        return pattern[type](input) if type
