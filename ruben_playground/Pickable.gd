extends StaticBody

onready var hitbox: CollisionShape = $CollisionShape
const IMAGE = preload("res://icon.png")
const NAME := "Relic"
const INTERACTION_LENGTH := 3.0


func get_item():
	return self


func pick_up():
	hitbox.disabled = true
	hide()
	get_parent().remove_child(self)


func get_item_logo():
	return IMAGE


func get_item_name():
	return NAME


func get_interaction_length() -> float:
	return INTERACTION_LENGTH

func interact() -> Node:
	return self
