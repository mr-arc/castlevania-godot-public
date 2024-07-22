extends Node

# Returns nodes that match the given predicate.
func findNodes(predicate: FuncRef, root: Node = null) -> Array:
	var matching = ObjArray.new()
	forEachMatching(predicate, funcref(matching, "append"), root)
	return matching.data
	
# Executes `operation` for each node that matches the given predicate.
func forEachMatching(predicate: FuncRef, operation: FuncRef, root: Node = null) -> void:
	if root == null:
		root = get_tree().root
	_traverse(predicate, operation, root)
	
func _accumulate(node: Node, arr: Array) -> void:
	arr.append(node)
	
func _traverse(predicate: FuncRef, operation: FuncRef, root: Node) -> void:
	var nodesToCheck = [root]

	while not nodesToCheck.empty():
		var node = nodesToCheck.pop_back()
		if predicate.call_func(node):
			operation.call_func(node)
		if node.get_child_count() > 0:
			nodesToCheck.append_array(node.get_children())

class ObjArray:
	var data = []
	
	func append(value) -> void:
		data.append(value)
