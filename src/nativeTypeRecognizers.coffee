check = Object.prototype.toString

module.exports =
  Int: (x) -> x == +x && x == (x|0)
  Float: (x) -> x == +x && x != (x|0)
  Number: (x) -> check.call(x) is '[object Number]' and not isNaN x
  String: (x) -> check.call(x) is '[object String]'
  Array: (x) -> check.call(x) is '[object Array]'
  Object: (x) -> check.call(x) is '[object Object]'
  NaN: (x) -> check.call(x) is '[object Number]' and isNaN x
