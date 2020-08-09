extends RigidBody

class_name DroppedItem

var item: Node = null

func set_item(new_item: Node):
	if item == null:
		item = new_item

func get_item() -> Node:
	return item
