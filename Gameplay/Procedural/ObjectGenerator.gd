class_name ObjectGenerator

var data_set: ObjectGeneratorDataSet

var _settings: ObjectGeneratorSettings
var _map_gen_data_set: MapGeneratorDataSet
var _rnd: RandomNumberGenerator

var __debug_root_node: Node
var __debug_object_material: ShaderMaterial

const __debug_diffuse_color_param_name: String = "DiffuseColor"
const __debug_shader: Shader = preload("res://Gameplay/Procedural/Debug/MapGeneratorDebugShader.tres")

func __debug_load_materials():
	__debug_object_material = ShaderMaterial.new()
	__debug_object_material.shader = __debug_shader
	__debug_object_material.set_shader_param(__debug_diffuse_color_param_name, Color.aquamarine)
	
func get_object_from_position(position: Vector2) -> ObjectInfo:
	for object in data_set.objects:
		if object.position == position:
			return object
			
	return null

func generate_new_objects(debug_root_node: Node = null) -> void:
	var matrix: Array
	
	__debug_root_node = debug_root_node

	if __debug_root_node != null:
		__debug_load_materials()
	
	_rnd = ProceduralHelper.rnd
	
	matrix = ProceduralHelper.map_generator.data_set.matrix
	
	_settings = ProceduralHelper.object_generator_settings
	_map_gen_data_set = ProceduralHelper.map_generator.data_set
	data_set = ObjectGeneratorDataSet.new()
	
	# We fill the rooms with random objects
	for room_info in _map_gen_data_set.rooms:
		var max_allowed_objs: int
		var area: Array
		var room_pos: Vector2
		var room_size: Vector2
		var objs_to_generate: int
		var obj_list: Array
		var area_size: Vector2
		
		room_pos = room_info.position
		room_size = room_info.size
		max_allowed_objs = 0
		
		# Initialize the local room area, without the walls
		# Basically, it's the matrix of the local tiles where we can place an object
		for y in range(0, room_info.size.y - 2):
			area.push_back([])
			
			for x in range(0, room_info.size.x - 2):
				
				# Check if we are near to an exit
				# We don't want to block them!
				if (x == 0 and matrix[room_pos.y + y + 1][room_pos.x].tile_type == TileType.Floor) \
				or (x == room_info.size.x - 3 and matrix[room_pos.y + y + 1][room_pos.x + room_info.size.x - 1].tile_type == TileType.Floor) \
				or (y == 0 and matrix[room_pos.y][room_pos.x + x + 1].tile_type == TileType.Floor) \
				or (y == room_info.size.y - 3 and matrix[room_pos.y + room_info.size.y - 1][room_pos.x + x + 1].tile_type == TileType.Floor):
					area[y].push_back(0)
				else:
					area[y].push_back(1)
					max_allowed_objs += 1
		
		# Get the max allowed objects to spawn in the room
		max_allowed_objs = (max_allowed_objs * _settings.object_max_allowed_modifier) as int
			
		# If no object can be spawn, skip...
		if max_allowed_objs == 0:
			continue
			
		if max_allowed_objs > _settings.object_max_generated:
			max_allowed_objs = _settings.object_max_generated
		elif max_allowed_objs < _settings.object_min_generated:
			max_allowed_objs = _settings.object_min_generated
		
		# Get the area size
		area_size.x = area[0].size()
		area_size.y = area.size()
		
		# Get a random number of objects to spawn
		objs_to_generate = _rnd.randi_range(1, max_allowed_objs)
		# Fetch the list of objects compatible with the current room
		obj_list = _settings.props[room_info.type]
		
		for _i in range(objs_to_generate):
			var obj_info: ObjectInfo
			var retry_count: int
			var can_place: bool
			var local_pos: Vector2
			
			# Get a random object
			obj_info = obj_list[_rnd.randi_range(0, obj_list.size() - 1)]
			# Get a new instance of its
			obj_info = clone_object_info(obj_info)
			
			can_place = false
			retry_count = 10
			
			# Try to place the object
			while retry_count > 0:
				var keep_going: bool
				
				keep_going = true
				
				# Get a new random local position
				local_pos = Vector2(
					_rnd.randi_range(0, area_size.x - 1),
					_rnd.randi_range(0, area_size.y - 1)
				)
				
				# Move the object back inside the area if it was outside
				if local_pos.x + obj_info.size.x - 1 >= area_size.x:
					local_pos.x -= area_size.x - local_pos.x + obj_info.size.x - 1
					
				if local_pos.y + obj_info.size.y - 1 >= area_size.y:
					local_pos.y -= area_size.y - local_pos.y + obj_info.size.y - 1
				
				# If any of the tile is already occupied, the object cannot be placed
				for y in range(obj_info.size.y):
					for x in range(obj_info.size.x):
						if area[local_pos.y + y][local_pos.x + x] == 0:
							keep_going = false
							break
					if not keep_going:
						break
									
				if not keep_going:
					retry_count -= 1
					continue
				
				# Check the neighbour tiles to keep room between exits and other objects
				for y in range(obj_info.size.y):
					for x in range(obj_info.size.x):
						if (x == 0 \
							and local_pos.x - 1 >= 0 \
							and area[local_pos.y + y][local_pos.x - 1] == 0) \
						or (x == obj_info.size.x - 1 \
							and local_pos.x + obj_info.size.x < area_size.x \
							and area[local_pos.y + y][local_pos.x + obj_info.size.x] == 0) \
						or (y == 0 \
							and local_pos.y - 1 >= 0 \
							and area[local_pos.y - 1][local_pos.x + x] == 0) \
						or (y == obj_info.size.y - 1 \
							and local_pos.y + obj_info.size.y < area_size.y \
							and area[local_pos.y + obj_info.size.y][local_pos.x + x] == 0) \
						or (x == 0 \
							and y == 0 \
							and local_pos.x - 1 >= 0 \
							and local_pos.y - 1 >= 0 \
							and area[local_pos.y - 1][local_pos.x - 1] == 0) \
						or (x == obj_info.size.x - 1 \
							and y == 0 \
							and local_pos.x + obj_info.size.x < area_size.x \
							and local_pos.y - 1 >= 0 \
							and area[local_pos.y - 1][local_pos.x + obj_info.size.x] == 0) \
						or (x == 0 \
							and y == obj_info.size.y - 1 \
							and local_pos.x - 1 >= 0 \
							and local_pos.y + obj_info.size.y < area_size.y \
							and area[local_pos.y + obj_info.size.y][local_pos.x - 1] == 0) \
						or (x == obj_info.size.x - 1 \
							and y == obj_info.size.y - 1 \
							and local_pos.x + obj_info.size.x < area_size.x \
							and local_pos.y + obj_info.size.y < area_size.y \
							and area[local_pos.y + obj_info.size.y][local_pos.x + obj_info.size.x] == 0):
								
							keep_going = false
							break
							
					if not keep_going:
						break
						
				if not keep_going:
					retry_count -= 1
					continue
					
				can_place = true
				# Update the object with the valided data
				obj_info.position = room_info.position + local_pos + Vector2(1, 1)
				break
				
			if not can_place:
				continue
				
			data_set.objects.push_back(obj_info)
			
			# Update the area
			for y in obj_info.size.y:
				for x in obj_info.size.x:
					area[local_pos.y + y][local_pos.x + x] = 0
			
	if __debug_root_node != null:
		__debug_render_objects(data_set.objects)
	
func __debug_render_objects(objects: Array):
	for object in objects:
		for y in object.size.y:
			for x in object.size.x:
				var cube: CSGBox
				
				cube = CSGBox.new()
				cube.width = ProceduralHelper.map_generator_settings.tile_size
				cube.height = ProceduralHelper.map_generator_settings.tile_size
				cube.depth = ProceduralHelper.map_generator_settings.tile_size
				cube.transform.origin = Vector3(
					(object.position.x + x) * ProceduralHelper.map_generator_settings.tile_size,
					1,
					(object.position.y + y) * ProceduralHelper.map_generator_settings.tile_size)
				
				cube.material = __debug_object_material
				__debug_root_node.add_child(cube)

func clone_object_info(input: ObjectInfo) -> ObjectInfo:
	return ObjectInfo.new(input.name, input.size)
