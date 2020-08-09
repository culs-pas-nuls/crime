extends Spatial

onready var interactables: Spatial = $Interactables


func _ready():
	var prop_data = {
		"logo": load("res://icon.png"),
		"name": "Relic",
		"length": 2
	}
	for interactable in interactables.get_children():
		interactable.init(prop_data)
