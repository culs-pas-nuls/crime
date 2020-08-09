extends RigidBody

class_name DroppedItem

onready var hitbox: CollisionShape = $Hitbox

var item: Node = null


func set_item(new_item: Node):
	if item == null:
		item = new_item


func get_item() -> Node:
	return item


func pick_up():
	hitbox.disabled = true
	hide()
	queue_free()
