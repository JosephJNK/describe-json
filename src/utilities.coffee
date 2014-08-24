
getAllNonemptyNodesInTree = (tree) ->
  return [] if tree is {}
  nodes = []
  for node, subtree of tree
    nodes.push node
    subnodes = getAllNonemptyNodesInTree subtree
    nodes.concat subnodes
  nodes

getOnlyKeyForObject = (x) -> Object.keys(x)[0]

checkType = Object.prototype.toString

module.exports =

  cloneFlatObject: (obj) ->
    clone = {}
    clone[fieldName] = fieldType for fieldName, fieldType of obj
    clone

  getAllNonemptyNodesInTree: getAllNonemptyNodesInTree

  getOnlyKeyForObject: getOnlyKeyForObject

  getOnlyValueForObject: (x) -> x[getOnlyKeyForObject(x)]

  beginsWithUpperCase: (x) -> x[0].toUpperCase() is x[0]

  beginsWithLowerCase: (x) -> x[0].toUpperCase() isnt x[0]

  checkType: checkType

  isString: (x) -> checkType.call(x) is '[object String]'

  isObject: (x) -> checkType.call(x) is '[object Object]'

  destructureSingleKey: (x) ->
    key = getOnlyKeyForObject x
    [key, x[key]]
