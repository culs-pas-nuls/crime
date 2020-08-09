extends RigidBody

class_name DroppedItem

onready var hitbox: CollisionShape = $Hitbox

var item: Reference = null


func set_item(new_item: Reference):
	if item == null:
		item = new_item


func get_item() -> Reference:
	return item


func pick_up():
	hitbox.disabled = true
	hide()
	queue_free()
