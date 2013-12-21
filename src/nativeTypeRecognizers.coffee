check = Object.prototype.toString

wrapNonContainer = (value, type) ->
  matched: true
  iscontainer: false
  type: type
  data: value

module.exports =
  Int: (x) ->
    res = matched: x == +x && x == (x|0)
    if res.matched then wrapNonContainer(x, 'Int') else res

  Float: (x) ->
    res = matched: x == +x && x != (x|0)
    if res.matched then wrapNonContainer(x, 'Float') else res

  Number: (x) -> check.call(x) is '[object Number]' and not isNaN x
  String: (x) -> check.call(x) is '[object String]'
  Array: (x) -> check.call(x) is '[object Array]'
  Object: (x) -> check.call(x) is '[object Object]'
  NaN: (x) -> check.call(x) is '[object Number]' and isNaN x
