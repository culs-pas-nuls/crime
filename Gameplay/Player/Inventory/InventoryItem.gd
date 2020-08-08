extends Button

class_name InventoryItem

var item = null

func set_item(new_item: Node):
	item = new_item

func get_item():
	return item
