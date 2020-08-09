class_name MapAssetPlacer

const __HALF_PI := PI * 0.5
const __UP := Vector3(0, 1, 0)

const __tiles := {}
const __walls := {}


func _init() -> void:
	var tileLibrary := preload("res://Assets/Tile/TileLibrary.tscn").instance()
	__tiles[RoomType.Bathroom] = tileLibrary.get_node("BathroomTile")
	__tiles[RoomType.Bedroom] = tileLibrary.get_node("BedroomTile")
	__tiles[RoomType.Kitchen] = tileLibrary.get_node("KitchenTile")
	__tiles[RoomType.Hallway] = tileLibrary.get_node("HallwayTile")
	
	var wallLibrary := preload("res://Assets/Wall/WallLibrary.tscn").instance()
	__walls[RoomType.Bathroom] = wallLibrary.get_node("BathroomWall")
	__walls[RoomType.Bedroom] = wallLibrary.get_node("BedroomWall")
	__walls[RoomType.Kitchen] = wallLibrary.get_node("KitchenWall")
	__walls[RoomType.Hallway] = wallLibrary.get_node("HallwayWall")


func placeAssets(origin: Node, map: Array) -> void:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	for y in range(map.size()):
		var sub: Array = map[y]
		for x in range(sub.size()):
			var tileInfo: TileInfo = sub[x]
			if tileInfo == null:
				continue
			var block: MeshInstance
			if tileInfo.tile_type == TileType.Wall:
				block = __walls[tileInfo.room_type]
			elif tileInfo.tile_type == TileType.Floor:
				block = __tiles[tileInfo.room_type]
			else:
				continue
			var generated: MeshInstance = block.duplicate()
			generated.transform.origin = Vector3(x, 0, y)
			#generated.rotate(__UP, __HALF_PI * rnd.randi_range(0, 3))
			origin.add_child(generated)
