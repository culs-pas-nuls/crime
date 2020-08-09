extends Button

class_name InventoryItem

onready var image = $Images
onready var label = $Label

var item: Node = null


func set_item(new_item: Node):
	item = new_item
	label.texture = new_item.item_logo
	label.text = new_item.item_name


func get_item() -> Node:
	return item


func clear_item():
	label.texture = null
	label.text = ""


func is_free() -> bool:
	return item == null
