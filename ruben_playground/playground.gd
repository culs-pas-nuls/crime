extends Spatial

onready var interactables: Spatial = $Interactables


func _ready():
	var logo = load("res://icon.png")
	var prop_data = {
		"logo": logo,
		"name": "Picked",
		"length": 2,
		"content_logo": logo,
		"content_name": "Interacted"
	}
	for interactable in interactables.get_children():
		interactable.init(prop_data)
