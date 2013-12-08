registeredTypes = {}

validateNewType = (newType) ->
  return 'newtype keyword missing' unless newType.newtype?
  return 'type must have a name' unless newType.newtype.name?
  return 'type already exists' if newType[types.newtype.name]?

module.exports =
  register: (type) ->
    name = type.newtype.name
    registeredTypes[name] = type.newtype
    null

  types: -> Object.keys registeredTypes
