extends Button

class_name InventoryItem

onready var image = $Image
onready var label = $Label

var item: Node = null


func set_item(new_item: Node):
	item = new_item
	image.texture = new_item.get_item_logo()
	label.text = new_item.get_item_name()


func get_item() -> Node:
	return item


func clear_item():
	image.texture = null
	label.text = ""
	item = null


func is_free() -> bool:
	return item == null
