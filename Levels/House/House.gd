extends Node

# Main script for the house level.

func _ready():
	generateLevel()

func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var map = generateMap()
	mapAssetPlacer.placeAssets(self, map)

func generateMap() -> Array:
	var map = []
	for i in range(10):
		var sub = []
		for j in range(10):
			var tileInfo = TileInfo.new()
			tileInfo.room_type = RoomType.Bathroom
			sub.append(tileInfo)
		map.append(sub)
	return map
