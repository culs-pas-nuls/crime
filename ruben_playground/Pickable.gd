extends StaticBody

onready var hitbox: CollisionShape = $CollisionShape
const IMAGE = preload("res://icon.png")
const NAME := "Relic"

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
