
{inspect} = require 'util'
nativeTypes = Object.keys require './nativeTypeRecognizers'

module.exports = (newType, recognizers) ->
  #recognizers :: {data -> bool}

#andCombinator :: [data -> bool] -> data -> bool
  andCombinator = (fns) ->
    (x) ->
      for fn in fns
        return false unless fn x
      true

#fieldCombinator :: data -> (data -> bool)
#fieldDeclarations :: [data]
  fieldCombinator = (fieldDeclarations) ->
    #fns :: [data -> bool]
    fieldRecognizers = []

    for fieldObj in fieldDeclarations
      fieldName = Object.keys(fieldObj)[0] #add validation that there is only one here to registration
      fieldType = fieldObj[fieldName]

      fieldRecognizer = (untypedData) ->
        console.log "untypedData: #{inspect untypedData}"
        fieldExists = untypedData[fieldName]?
        console.log "field exists: #{fieldExists}"
        if fieldExists
          fieldRecognized = recognize fieldType, untypedData[fieldName]
          console.log "field recognized: #{fieldRecognized}"
          return fieldRecognized
        false

      fieldRecognizers.push fieldRecognizer

    return andCombinator fieldRecognizers

  #trampoline :: (data -> bool) -> data -> bool
  trampoline = (parentRecognizer) ->
    console.log "bound recognizer to trampoline: #{parentRecognizer}"
    (initialArg) ->
      console.log "inside trampoline, initialArg: #{initialArg}"
      [childType, childNode, matched] = parentRecognizer childNode
      return matched unless matched is null
      return recognizers[childType] childNode

  #recognize :: data -> data -> bool
  recognize = (typeName, untypedObj) ->
    if nativeTypes.indexOf typeName isnt -1
      return recognizers[typeName] untypedObj
    trampoline(recognizers[typeName]) untypedObj

  if newType.fields?
    #fieldsRecognizer :: data -> bool
    fieldsRecognizer = fieldCombinator newType.fields
    console.log "got fieldsRecognizer: #{inspect fieldsRecognizer}"
    return fieldsRecognizer

