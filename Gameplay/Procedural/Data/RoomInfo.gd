class_name RoomInfo

var size: Vector2
var position: Vector2

func get_left() -> int:
	return position.x as int
	
func get_right() -> int:
	return (position.x + size.x - 1) as int
	
func get_top() -> int:
	return position.y as int
	
func get_bottom() -> int:
	return (position.y + size.y - 1) as int

func set_left(value: int) -> void:
	position.x = value
	
func set_right(value: int) -> void:
	size.x = value - position.x + 1
	
func set_top(value: int) -> void:
	position.y = value
	
func set_bottom(value: int) -> void:
	size.y = value - position.y + 1
