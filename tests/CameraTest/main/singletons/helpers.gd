extends Node


func delete_children(node: Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
