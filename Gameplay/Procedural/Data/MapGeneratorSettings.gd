extends Node

class_name MapGeneratorSettings

# A floor unit
var tile_size: int = 1
# Play field size
var grid_size: Vector2 = Vector2(80, 40)

# Min room size
var room_min_size: int = 8
# Max room size
var room_max_size: int = 16

# Min room count
var room_min_count: int = 8
# Max room count
var room_max_count: int = 16

var hallway_width: int = 5
