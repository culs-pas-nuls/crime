class_name PathFinder

var _astar: AStar
var _ids: Array
var _current_id: int

func reset():
	_astar = AStar.new()
	_current_id = 0
	
	for y in range(ProceduralHelper.map_generator_settings.grid_size.y):
		_ids.push_back([])
		
		for x in range(ProceduralHelper.map_generator_settings.grid_size.x):
			_ids[y].push_back(-1)
	
	for y in range(ProceduralHelper.map_generator_settings.grid_size.y):
		for x in range(ProceduralHelper.map_generator_settings.grid_size.x):
			if not ProceduralHelper.is_tile_walkable(Vector2(x, y)):
				continue
				
			_register_point(Vector2(x, y))
			
			for offset_y in range(-1, 2):
				for offset_x in range(-1, 2):
					var is_diagonal: bool
					
					is_diagonal = \
							offset_x == offset_y \
						or (offset_x == 1 and offset_y == -1) \
						or (offset_x == -1 and offset_y == 1)
						
					if is_diagonal:
						continue
					
					if not ProceduralHelper.is_tile_walkable(Vector2(x + offset_x, y + offset_y)):
						continue
					
					if _ids[y + offset_y][x + offset_x] == -1:
						_register_point(Vector2(x + offset_x, y + offset_y))
						
					_astar.connect_points(_ids[y][x], _ids[y + offset_y][x + offset_x])

func _register_point(point: Vector2) -> void:
	_astar.add_point(_current_id, Vector3(point.x, 0, point.y))
	_ids[point.y][point.x] = _current_id
	_current_id += 1
	
func get_random_path_from_position(position: Vector2) -> Array:
	var target_index: int
	var from_index: int
	var raw_path: PoolVector3Array
	var path: Array
	
	path = []
	from_index = _ids[position.y][position.x]
	
	if from_index == -1:
		return []
	
	while true:
		target_index = ProceduralHelper.rnd.randi_range(0, _current_id - 1)
		
		if target_index != from_index:
			break
		
	raw_path = _astar.get_point_path(from_index, target_index)
	
	for point in raw_path:
		path.push_back(ProceduralHelper.to_matrix_position(point))
		
	return path
