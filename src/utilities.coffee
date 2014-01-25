
getAllNonemptyNodesInTree = (tree) ->
  return [] if tree is {}
  nodes = []
  for node, subtree of tree
    nodes.push node
    subnodes = getAllNonemptyNodesInTree subtree
    nodes.concat subnodes
  nodes

module.exports =
  cloneFlatObject: (obj) ->
    clone = {}
    clone[fieldName] = fieldType for fieldName, fieldType of obj
    clone

  getAllNonemptyNodesInTree: getAllNonemptyNodesInTree
