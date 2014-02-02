{checkType, isString} = require './utilities'

wrapNonContainer = (value, type) ->
  matched: true
  data: value
  typedata:
    type: type
    iscontainer: false

module.exports =
  Integer: (x) ->
    res = matched: x == +x && x == (x|0)
    if res.matched then wrapNonContainer(x, 'Integer') else res

  Float: (x) ->
    res = matched: x == +x && x != (x|0)
    if res.matched then wrapNonContainer(x, 'Float') else res

  Number: (x) ->
    res = matched: checkType.call(x) is '[object Number]' and not isNaN x
    if res.matched then wrapNonContainer(x, 'Number') else res

  String:
    (x) ->
      res = matched: isString x
      if res.matched then wrapNonContainer(x, 'String') else res

  NaN: (x) ->
    res = matched: checkType.call(x) is '[object Number]' and isNaN x
    if res.matched then wrapNonContainer(x, 'NaN') else res

  Null: (x) ->
    res = matched: x is null
    if res.matched then wrapNonContainer(x, 'Null') else res

  Undefined: (x) ->
    res = matched: x is undefined
    if res.matched then wrapNonContainer(x, 'Undefined') else res

  Array: (x) ->
    matched = checkType.call(x) is '[object Array]'
    if matched
      matched: true
      data: x
      typedata:
        type: 'Array'
        iscontainer: true
        fields: []
    else
      matched: false

  Object: (x) ->
    matched = checkType.call(x) is '[object Object]'
    if matched
      matched: true
      data: x
      typedata:
        type: 'Object'
        iscontainer: true
        fields: {}
    else
      matched: false
