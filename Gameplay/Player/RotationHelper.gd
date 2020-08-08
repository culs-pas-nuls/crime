extends Spatial

class_name RotationHelper

const ROTATION_AXIS: Vector3 = Vector3(0, 1, 0)
onready var model: Spatial = get_node("character")

func _ready():
    pass # Replace with function body.

func set_orientation(new_orientation: Vector3):
    look_at(global_transform.origin + new_orientation, ROTATION_AXIS)
