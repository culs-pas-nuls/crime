extends StaticBody

class_name PickableProp

onready var hitbox: CollisionShape = $CollisionShape

var _ITEM: Reference = null


# The `data` dictionnary expects two keys:
#	"logo" the item logo (StreamTexture)
#	"name" the item name (String)
func init(data: Dictionary):
	if _ITEM == null:
		var logo = data["logo"]
		var name = data["name"]
		_ITEM = load("res://Gameplay/Props/Item.gd").new(logo, name)


func get_item():
	return _ITEM


func pick_up():
	hitbox.disabled = true
	hide()
	get_parent().remove_child(self)
