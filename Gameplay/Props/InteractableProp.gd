extends PickableProp

class_name InteractableProp

var _LENGTH := 1.0

# The `data` dictionnary expects same keys as PickableProp plus:
#	"length" the item logo (StreamTexture)
func init(data: Dictionary):
	.init(data)
	_LENGTH = data["length"]


func get_interaction_length() -> float:
	return _LENGTH
