extends StaticBody

class_name PickableProp

onready var hitbox: CollisionShape = $Hitbox

var _ITEM: Reference = null
var _ITEM_LOGO: StreamTexture = null
var _ITEM_NAME := ""


# The `data` dictionnary expects two keys:
#	"logo" the item logo (StreamTexture)
#	"name" the item name (String)
func init(data: Dictionary):
	if _ITEM == null:
		_ITEM_LOGO = data["logo"]
		_ITEM_NAME = data["name"]
		_ITEM = load("res://Gameplay/Props/Item.gd").new(_ITEM_LOGO, _ITEM_NAME)


func get_item():
	return _ITEM


func pick_up():
	hitbox.disabled = true
	hide()
	get_parent().remove_child(self)
