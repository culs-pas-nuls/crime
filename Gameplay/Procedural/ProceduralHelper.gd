extends Node

var map_generator: MapGenerator
var map_generator_settings: MapGeneratorSettings
var object_generator: ObjectGenerator
var object_generator_settings: ObjectGeneratorSettings
var path_finder: PathFinder
var rnd : RandomNumberGenerator

func _init():
	map_generator = MapGenerator.new()
	map_generator_settings = MapGeneratorSettings.new()
	object_generator = ObjectGenerator.new()
	object_generator_settings = ObjectGeneratorSettings.new()
	path_finder = PathFinder.new()
	rnd = RandomNumberGenerator.new()
	rnd.randomize()

func is_tile_walkable(position: Vector2) -> bool:
	var object_info: ObjectInfo
	
	object_info = object_generator.get_object_from_position(position)
	
	if object_info != null:
		return false
		
	if map_generator.data_set.matrix[position.y][position.x] == null \
	or map_generator.data_set.matrix[position.y][position.x].tile_type != TileType.Floor:
		return false
	
	return true
	
func is_close_to_matrix_position(position: Vector3, target: Vector2, tolerance: float) -> bool:
	return \
		position.x >= target.x - tolerance \
	and position.x <= target.x + tolerance \
	and position.z >= target.y - tolerance \
	and position.z <= target.y + tolerance
	
func to_matrix_position(position: Vector3) -> Vector2:
	return Vector2(
		(position.x / map_generator_settings.tile_size) as int,
		(position.z / map_generator_settings.tile_size) as int)
		
func to_world_position(position: Vector2, height: float) -> Vector3:
	return Vector3(
		position.x * ProceduralHelper.map_generator_settings.tile_size,
		height,
		position.y * ProceduralHelper.map_generator_settings.tile_size
	)
