extends Control

class_name Inventory

const InventoryItemScn = preload("./InventoryItem.tscn")

signal on_InventoryItem_click(inventory_item)

const MAX_SIZE := 15
var INVENTORY_SIZE := 0
var used_size := 0
var inventory := []

onready var ui_container = $CenterContainer/Panel/MarginContainer/GridContainer


func init(size: int):
	if inventory or inventory.size() > MAX_SIZE: return
	INVENTORY_SIZE = size

	for _i in range(size):
		var item = InventoryItemScn.instance()
		inventory.append(item)
		ui_container.add_child(item)
		item.connect("pressed", self, "_on_InventoryItem_click", [item])


func add_item(new_item: Node) -> bool:
	if not inventory or used_size >= INVENTORY_SIZE:
		return false


	var index = _find_first_free()
	inventory[index].set_item(new_item)
	used_size += 1
	return true


func remove_item(inventory_item: Node) -> bool:
	if not inventory or used_size == 0:
		return false

	inventory_item.clear_item()
	used_size -= 1
	return true


func get_content() -> Array:
	if not inventory or used_size == 0:
		return []

	var content = []
	for inventory_item in inventory:
		if not inventory_item.is_free():
			content.append(inventory_item.get_item())
	return content


func _find_first_free():
	for i in range(inventory.size()):
		if inventory[i].is_free():
			return i
	return -1


func _on_InventoryItem_click(inventory_item: InventoryItem):
	emit_signal("on_InventoryItem_click", inventory_item)
