class_name MapGenerator

# Private

var _settings: MapGeneratorSettings
var _data_set: MapGeneratorDataSet
var _rnd: RandomNumberGenerator
var __debug_material_cache: Array
var __debug_floor_material: ShaderMaterial
var __debug_wall_material: ShaderMaterial
var __debug_root_node: Node

# Constants

const __debug_shader: Shader = preload("res://Gameplay/Procedural/Debug/MapGeneratorDebugShader.tres")
const __debug_diffuse_color_param_name: String = "DiffuseColor"
const __debug_color_list: Array = [
	Color.red,
	Color.blue,
	Color.green,
	Color.orange,
	Color.yellow,
	Color.violet,
	Color.cyan,
	Color.magenta,
	Color.blueviolet,
	Color.chocolate]
	
func generateNewMap(debug_root_node: Node = null) -> Array:
	_settings = MapGeneratorSettings.new()
	_data_set = MapGeneratorDataSet.new()
	_rnd = RandomNumberGenerator.new()
	
	__debug_root_node = debug_root_node
	
	if __debug_root_node != null:
		__debug_load_materials()
		__debug_generate_material_cache()
		
	_rnd.randomize()
	_generate()
	
	if __debug_root_node != null:
		__debug_render_map()
	
	return _data_set.matrix

func _generate() -> void:
	var total_tiles: int
	var max_tiles: int
	var room_generation_count: int
	var rooms_to_link_indices: Array
	var linked_rooms_indices: Array
	
	# Will store the number of tiles used for generation
	total_tiles = 0
	# Get the max tile count allowed with the defined grid size
	max_tiles = _settings.grid_size.x * _settings.grid_size.y
	# How many rooms to generate?
	room_generation_count = _rnd.randi_range(_settings.room_min_count, _settings.room_max_count)

	# Matrix initialization
	_data_set.matrix = []
	for y in range(_settings.grid_size.y):
		_data_set.matrix.push_back([])
		for x in range(_settings.grid_size.x):
			_data_set.matrix[y].push_back(null)
	
	# Let's generate the mess!
	for _i in range(room_generation_count):
		var room_info: RoomInfo
		var retry_count: int
		var can_add: bool
		
		room_info = RoomInfo.new()
			
		can_add = false
		retry_count = 0
			
		while retry_count < 10:
			var is_inside: bool
			
			is_inside = false
			
			# New random size
			room_info.size = Vector2(
				_rnd.randi_range(_settings.room_min_size, _settings.room_max_size),
				_rnd.randi_range(_settings.room_min_size, _settings.room_max_size))
			
			# New random position
			room_info.position = Vector2(
				_rnd.randi_range(0, _settings.grid_size.x - room_info.size.x - 1),
				_rnd.randi_range(0, _settings.grid_size.y - room_info.size.y - 1))
			
			# We are going to shrink the room if it overlaps another one
			for other_room_info in _data_set.rooms:
				if 		room_info.get_left() <= other_room_info.get_right() \
				and 	room_info.get_right() >= other_room_info.get_left() \
				and 	room_info.get_top() <= other_room_info.get_bottom() \
				and 	room_info.get_bottom() >= other_room_info.get_top():
						
						if room_info.get_left() < other_room_info.get_left():
							room_info.set_right(other_room_info.get_left() - 1)
						elif room_info.get_right() > other_room_info.get_right():
							room_info.set_left(other_room_info.get_right() + 1)
						elif room_info.get_top() < other_room_info.get_top():
							room_info.set_bottom(other_room_info.get_top() - 1)
						elif room_info.get_bottom() > other_room_info.get_bottom():
							room_info.set_top(other_room_info.get_bottom() + 1)
						else:
							# Special case of overlap: the room is inside another one
							is_inside = true
			
			if not is_inside:
				# Shrink the room if it is outside the grid limits
				if room_info.get_right() >= _settings.grid_size.x:
					room_info.set_right(_settings.grid_size.x - 1)
					
				if room_info.get_bottom() >= _settings.grid_size.y:
					room_info.set_bottom(_settings.grid_size.y - 1)
				
				# We (probably) got a new room size, but is it still valid?
				if room_info.size.x >= _settings.room_min_size and room_info.size.y >= _settings.room_min_size:
					# Yes, congratulations, we have a new room!
					can_add = true
					break
			
			# Nope, try again
			retry_count += 1
		
		# All attempts failed, sorry
		if not can_add:
			continue
		
		# How many tiles are we going to eat?
		total_tiles += room_info.size.x * room_info.size.y
		
		# Too many, so plz stahp
		if total_tiles > max_tiles:
			break

		_data_set.rooms.push_back(room_info)
		
		# The room is now projected into the matrix
		for y in room_info.size.y:
			for x in room_info.size.x:
				var tile_info: TileInfo
				var is_wall: bool
				
				# If the tile is on the bound of the room, it's a wall
				is_wall = \
					   y == 0 \
					or y == room_info.size.y - 1 \
					or x == 0 \
					or x == room_info.size.x - 1

				tile_info = TileInfo.new()
				tile_info.room_id = _data_set.rooms.size() - 1
				tile_info.tile_type = TileType.Wall if is_wall else TileType.Floor
				tile_info.room_type = RoomType.allowed_values[_rnd.randi_range(0, RoomType.allowed_values.size() - 1)]
				_data_set.matrix[room_info.position.y + y][room_info.position.x + x] = tile_info
		
	rooms_to_link_indices = range(_data_set.rooms.size())
	linked_rooms_indices = []
	
	# We create room connections
	while rooms_to_link_indices.size() > 0:
		var from_room_index: int
		var to_room_index: int
		var from_room: RoomInfo
		var to_room: RoomInfo
		var from_pos: Vector2
		var to_pos: Vector2
		var last_x_pos: int
		var direction: int
		var hallway_offset_bound: int
		var extra: int
		
		# Take the first room that is not linked yet
		from_room_index = rooms_to_link_indices.pop_front()

		# Select the room to which we want to connect
		# Priority to already linked rooms to avoid a potential isolation
		if linked_rooms_indices.size() > 0:
			to_room_index = linked_rooms_indices[_rnd.randi_range(0, linked_rooms_indices.size() - 1)]
		else:
			to_room_index = rooms_to_link_indices[_rnd.randi_range(0, rooms_to_link_indices.size() - 1)]
			rooms_to_link_indices.remove(rooms_to_link_indices.find(to_room_index))
			
		linked_rooms_indices.push_back(from_room_index)
		if linked_rooms_indices.find(to_room_index) == -1:
			linked_rooms_indices.push_back(to_room_index)
		
		# Get the room info
		from_room = _data_set.rooms[from_room_index]
		to_room = _data_set.rooms[to_room_index]

		# Select a random origin within the selected rooms (without the walls)
		from_pos = \
			from_room.position + \
			Vector2(1, 1) + \
			Vector2(
				_rnd.randi_range(0, from_room.size.x - 2),
				_rnd.randi_range(0, from_room.size.y - 2))
		to_pos = \
			to_room.position + \
			Vector2(1, 1) + \
			Vector2(
				_rnd.randi_range(0, to_room.size.x - 2),
				_rnd.randi_range(0, to_room.size.y - 2))

		# TODO: refactoring...
		
		# In which direction the hallway is going to expand
		direction = 1 if to_pos.x > from_pos.x else -1
		# Calculate the bound needed by the range used in the offset loop
		hallway_offset_bound = (_settings.hallway_width / 2) as int
		# Calculate the extra hallway tiles to generate to smoothen the curves
		extra = hallway_offset_bound * direction
		
		# Let's join the rooms!
		# Horizontally first
		for x in range(from_pos.x, to_pos.x + extra, direction):
			var tile_info: TileInfo
			
			last_x_pos = x
			
			# Enlarge path
			for offset in range(-hallway_offset_bound, hallway_offset_bound + 1):
				var is_hallway_wall: bool
				
				# Check if the hallway is not outside the grid
				if from_pos.y + offset < 0 or from_pos.y + offset >= _settings.grid_size.y:
					continue
				
				# Destroy walls that are on the path of the hallway
				if _data_set.matrix[from_pos.y + offset][x] != null:
					if _data_set.matrix[from_pos.y + offset][x].tile_type == TileType.Wall:
						_data_set.matrix[from_pos.y + offset][x].tile_type = TileType.Floor
					continue
				
				# Is the tile the hallway wall?
				is_hallway_wall = abs(offset) == hallway_offset_bound
				
				tile_info = TileInfo.new()
				tile_info.room_id = -1
				tile_info.tile_type = TileType.Wall if is_hallway_wall else TileType.Floor
				tile_info.room_type = RoomType.Hallway
				_data_set.matrix[from_pos.y + offset][x] = tile_info
				
		last_x_pos -= extra
		direction = 1 if to_pos.y > from_pos.y else -1
		
		# Vertically then
		for y in range(from_pos.y - extra, to_pos.y, direction):
			var tile_info: TileInfo
			
			# Enlarge path
			for offset in range(-hallway_offset_bound, hallway_offset_bound + 1):
				var is_hallway_wall: bool
				
				if last_x_pos + offset < 0 or last_x_pos + offset >= _settings.grid_size.x:
					continue
					
				if _data_set.matrix[y][last_x_pos + offset] != null:
					if _data_set.matrix[y][last_x_pos + offset].tile_type == TileType.Wall:
						_data_set.matrix[y][last_x_pos + offset].tile_type = TileType.Floor
					continue
					
				is_hallway_wall = abs(offset) == hallway_offset_bound
				
				tile_info = TileInfo.new()
				tile_info.room_id = -1
				tile_info.tile_type = TileType.Wall if is_hallway_wall else TileType.Floor
				tile_info.room_type = RoomType.Hallway
				_data_set.matrix[y][last_x_pos + offset] = tile_info
	
	# Extra pass to add the missing walls
	for y in range(_settings.grid_size.y):
		for x in range(_settings.grid_size.x):
			var must_be_wall: bool
			
			# If the tile is null or is already a wall, skip...
			if _data_set.matrix[y][x] == null or _data_set.matrix[y][x].tile_type == TileType.Wall:
				continue
			
			# It must be a wall if the tile is on the bounds of the grid
			must_be_wall = \
				x == 0 \
				or y == 0 \
				or x == _settings.grid_size.x - 1 \
				or y == _settings.grid_size.y - 1
			
			if must_be_wall:
				_data_set.matrix[y][x].tile_type = TileType.Wall
				continue
			
			# Check the tile neighbours and look for "void" tiles
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 2):
					# Don't take diagonals
					if offset_x == offset_y \
					or (offset_x == 1 and offset_y == -1) \
					or (offset_x == -1 and offset_y == 1):
						continue
					
					# One of the neighbour is empty, the tile must be a wall
					if _data_set.matrix[y + offset_y][x + offset_x] == null:
						must_be_wall = true
						break
						
			if must_be_wall:
				_data_set.matrix[y][x].tile_type = TileType.Wall
				continue
	
func __debug_render_map():
	# For debug purpose only
	for y in range(_settings.grid_size.y):
		for x in range(_settings.grid_size.x):
			var cube: CSGBox
			
			if _data_set.matrix[y][x] == null:
				continue
			
			cube = CSGBox.new()
			cube.width = _settings.tile_size
			cube.height = _settings.tile_size
			cube.depth = _settings.tile_size
			cube.transform.origin = Vector3(
				x * _settings.tile_size,
				0,
				y * _settings.tile_size)
			
			if _data_set.matrix[y][x].tile_type == TileType.Wall:
				cube.material = __debug_wall_material
			else:
				if _data_set.matrix[y][x].room_type != RoomType.Hallway:
					cube.material = __debug_material_cache[_data_set.matrix[y][x].room_id % __debug_material_cache.size()]
				else:
					cube.material = __debug_floor_material
				
			__debug_root_node.add_child(cube)

func __debug_load_materials():
	__debug_floor_material = ShaderMaterial.new()
	__debug_floor_material.shader = __debug_shader
	__debug_floor_material.set_shader_param(__debug_diffuse_color_param_name, Color.white)
	
	__debug_wall_material = ShaderMaterial.new()
	__debug_wall_material.shader = __debug_shader
	__debug_wall_material.set_shader_param(__debug_diffuse_color_param_name, Color.gray)
	
func __debug_generate_material_cache():
	for i in range(__debug_color_list.size()):
		var material: ShaderMaterial
		
		material = ShaderMaterial.new()
		material.shader = __debug_shader
		material.set_shader_param(__debug_diffuse_color_param_name, __debug_color_list[i])
		__debug_material_cache.push_back(material)
