extends PickableProp

class_name InteractableProp

var _CONTENT: Reference = null
var _LENGTH := 1.0

var _interacted := false

# The `data` dictionnary expects same keys as PickableProp plus:
#	"length" the time it takes to interact (float)
#	"content_logo" the content's logo (StreamTexture)
#	"content_name" the content's name (String)
func init(data: Dictionary):
	.init(data)
	_LENGTH = data["length"]
	var content_logo = data["content_logo"]
	var content_name = data["content_name"]
	_CONTENT = load("res://Gameplay/Props/Item.gd").new(content_logo, content_name)


func get_interaction_length() -> float:
	return _LENGTH if _CONTENT != null else -1


func interact() -> Reference:
	var result = _CONTENT if _CONTENT != null else null
	_CONTENT = null
	return result
