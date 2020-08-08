extends Control

class_name Inventory

const inventory_item = preload("./InventoryItem.tscn")

const MAX_SIZE := 15
var inventory := []

onready var ui_container = $CenterContainer/Panel/MarginContainer/GridContainer


func init(size: int):
	if inventory.size() > MAX_SIZE: return

	for _i in range(size):
		var item = inventory_item.instance()
		inventory.append(item)
		ui_container.add_child(item)


func add_item(new_item: Node) -> bool:
	if not inventory or inventory.size() == MAX_SIZE:
		return false
	inventory.append(new_item)
	return false


func remove_item(index: int) -> bool:
	if not inventory: return false
	return false


func get_item(index: int) -> Node:
	if not inventory: return null
	return null


func get_content() -> Array:
	if not inventory: return []
	return []
