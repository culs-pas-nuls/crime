extends Node

var map_generator: MapGenerator
var map_generator_settings: MapGeneratorSettings
var object_generator: ObjectGenerator
var object_generator_settings: ObjectGeneratorSettings
var path_finder: PathFinder
var rnd : RandomNumberGenerator

const INFINITE_MATRIX_DIST: float = 1000.0

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
	
	# Nope if there's an object
	if object_generator.data_set.matrix[position.y][position.x] == 1:
		return false
	
	# Nope if it's not a floor
	if map_generator.data_set.matrix[position.y][position.x] == null \
	or map_generator.data_set.matrix[position.y][position.x].tile_type != TileType.Floor:
		return false
	
	return true
	
func is_close_to_matrix_position(position: Vector3, target: Vector2, tolerance: float) -> bool:
	return \
		position.x >= target.x - tolerance \
	and position.x <= target.x + 1 + tolerance \
	and position.z >= target.y - tolerance \
	and position.z <= target.y + 1 + tolerance
	
func find_closest_walkable_tile_position(position: Vector3) -> Vector2:
	var matrix_pos: Vector2
	var flat_pos: Vector2
	var last_dist: float
	var last_pos: Vector2
	
	# Get the matrix position
	matrix_pos = to_matrix_position(position)
	# Flatten the world position
	flat_pos = Vector2(position.x, position.z)
	
	# Is the current tile already walkable?
	if is_tile_walkable(matrix_pos):
		return matrix_pos
	
	last_dist = INFINITE_MATRIX_DIST
	last_pos = Vector2(-1, -1)
	 
	# Let's check the neighbour tiles
	for offset_y in range(-1, 2):
		for offset_x in range(-1, 2):
			var is_diagonal: bool
			var dist: float
			var neighbour_matrix_pos: Vector2
			
			# Get the neighbour location
			neighbour_matrix_pos = Vector2(matrix_pos.x + offset_x, matrix_pos.y + offset_y)
					
			# The neighbour is outside, skip
			if neighbour_matrix_pos.x < 0 or neighbour_matrix_pos.x >= map_generator_settings.grid_size.x \
			or neighbour_matrix_pos.y < 0 or neighbour_matrix_pos.y >= map_generator_settings.grid_size.y:
				continue

			is_diagonal = \
					offset_x == offset_y \
				or (offset_x == 1 and offset_y == -1) \
				or (offset_x == -1 and offset_y == 1)
			
			# Don't check the diagonals
			if is_diagonal:
				continue
			
			# If the tile is not walkable, skip
			if not is_tile_walkable(neighbour_matrix_pos):
				continue
			
			# Found a candidate, let's see if it's closer than the previous one
			dist = (flat_pos - neighbour_matrix_pos).length()
			
			if dist < last_dist:
				# Yup, keep it
				last_dist = dist
				last_pos = neighbour_matrix_pos
				
	return last_pos
	
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
