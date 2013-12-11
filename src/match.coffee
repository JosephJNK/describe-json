
matchTypeFields = (input, typeData) -> null
matchTypeFieldTypes = (input, typeData) -> null

module.exports = (input, typeData) ->

  if matchTypeFields input, typeData
    return matchTypeFieldTypes input, typeData


