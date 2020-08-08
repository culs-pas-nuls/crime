extends Node

class_name RoomInfo

var size: Vector2
var position: Vector2
var is_linked: bool
var is_partially_linked: bool
var linked_neighbour_rooms: Array

func get_left() -> int:
	return position.x as int
	
func get_right() -> int:
	return (position.x + size.x) as int
	
func get_top() -> int:
	return position.y as int
	
func get_bottom() -> int:
	return (position.y + size.y) as int

func set_left(value: int) -> void:
	position.x = value
	
func set_right(value: int) -> void:
	size.x = value - position.x
	
func set_top(value: int) -> void:
	position.y = value
	
func set_bottom(value: int) -> void:
	size.y = value - position.y
