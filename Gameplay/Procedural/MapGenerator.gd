extends Node

var model_node: Node

var _settings: MapGeneratorSettings
var _data_set: MapGeneratorDataSet
var _rnd: RandomNumberGenerator

func _ready() -> void:
	_settings = MapGeneratorSettings.new()
	_data_set = MapGeneratorDataSet.new()
	_rnd = RandomNumberGenerator.new()
	_rnd.randomize()
	_generate()

func _generate() -> void:
	var total_tiles: int
	var max_tiles: int
	
	total_tiles = 0
	max_tiles = _settings.grid_size.x * _settings.grid_size.y

	for i in range(_settings.room_min_count,_settings.room_max_count + 1):
		var room_info: RoomInfo
		var retry_count: int
		var can_add: bool
		
		room_info = RoomInfo.new()
		room_info.size = Vector2(
			_rnd.randi_range(_settings.room_min_size, _settings.room_max_size + 1),
			_rnd.randi_range(_settings.room_min_size, _settings.room_max_size + 1))
			
		total_tiles += room_info.size.x * room_info.size.y
		
		if total_tiles > max_tiles:
			break
			
		can_add = false
			
		while retry_count < 5:
			room_info.position = Vector2(
				_rnd.randi_range(0, _settings.grid_size.x - room_info.size.x + 1),
				_rnd.randi_range(0, _settings.grid_size.y - room_info.size.y + 1))
				
			for other_room_info in _data_set.rooms:
				if room_info.get_left() > other_room_info.get_left() and room_info.get_left() < other_room_info.get_right():
					if room_info.get_top() > other_room_info.get_top() and room_info.get_top() < other_room_info.get_bottom():
						room_info.set_left(other_room_info.get_right())
						room_info.set_top(other_room_info.get_bottom())
					elif room_info.get_bottom() > other_room_info.get_top() and room_info.get_bottom() < other_room_info.get_bottom():
						room_info.set_left(other_room_info.get_right())
						room_info.set_bottom(other_room_info.get_top())
						
				elif room_info.get_right() > other_room_info.get_left() and room_info.get_right() < other_room_info.get_right():
					if room_info.get_top() > other_room_info.get_top() and room_info.get_top() < other_room_info.get_bottom():
						room_info.set_right(other_room_info.get_left())
						room_info.set_top(other_room_info.get_bottom())
					elif room_info.get_bottom() > other_room_info.get_top() and room_info.get_bottom() < other_room_info.get_bottom():
						room_info.set_right(other_room_info.get_left())
						room_info.set_bottom(other_room_info.get_top())
				
			if room_info.size.x >= _settings.room_min_size and room_info.size.y >= _settings.room_min_size:
				can_add = true
				break

			retry_count += 1
				
		if not can_add:
			continue

		_data_set.rooms.push_front(room_info)
		
	for room_info in _data_set.rooms:
			for y in range(room_info.size.y):
				for x in range(room_info.size.x):
					var cube: CSGBox
					
					cube = CSGBox.new()
					cube.width = _settings.tile_size
					cube.height = _settings.tile_size
					cube.depth = _settings.tile_size
					cube.transform.origin = Vector3(
						room_info.position.x + x * _settings.tile_size,
						0,
						room_info.position.y + y * _settings.tile_size)
					add_child(cube)
