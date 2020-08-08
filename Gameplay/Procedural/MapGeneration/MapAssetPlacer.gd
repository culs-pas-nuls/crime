class_name MapAssetPlacer

var __tile: MeshInstance = preload("res://Assets/Tile/Tile.tscn").instance().get_node("Cube")
var __tiles := {}
var __tileData := {
	RoomType.Bathroom: [Color.white],
	RoomType.Bedroom: [Color.green],
	RoomType.Kitchen: [Color.cyan],
	RoomType.Hallway: [Color.red],
	RoomType.Default: [Color.black],
}

func _init() -> void:
	for room_type in __tileData.keys():
		var room_data = __tileData[room_type]
		var color = room_data[0]
		var tile: MeshInstance = __tile.duplicate()
		var material = tile.get_surface_material(0).duplicate()
		material.albedo_color = color
		tile.set_surface_material(0, material)
		__tiles[room_type] = tile

func placeAssets(origin: Node, map: Array) -> void:
	for y in range(map.size()):
		var sub: Array = map[y]
		for x in range(sub.size()):
			var tileInfo: TileInfo = sub[x]
			var tile: MeshInstance = __tiles[tileInfo.room_type].duplicate()
			tile.transform.origin = Vector3(x, 0, y)
			origin.add_child(tile)
