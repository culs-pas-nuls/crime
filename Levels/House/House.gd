extends Node

# Main script for the house level.

var playerScene = preload("res://Gameplay/Player/player.tscn").instance()
var coombaScene = preload("res://Gameplay/AI/Coomba.tscn").instance()


func _ready():
	generateLevel()


func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var mapGenerator = MapGenerator.new()
	var obj_generator = ObjectGenerator.new()
	var propsAssetPlacer = PropsAssetPlacer.new()
	var map_data_set = mapGenerator.generate_new_map()
	var spawnPoint = mapAssetPlacer.placeAssets(self, map_data_set.matrix)
	var objects: Array = obj_generator.generate_new_objects(map_data_set)
	propsAssetPlacer.placeProps(self, objects)
	__placeAi(self, map_data_set.matrix)
	playerScene.transform.origin = spawnPoint
	add_child(playerScene)


func __placeAi(root: Node, map: Array) -> void:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	for y in range(map.size()):
		var sub = map[y]
		for x in range(sub.size()):
			var tileInfo = sub[x]
			if \
				tileInfo != null and \
				tileInfo.tile_type == TileType.Floor and \
				rnd.randf() > .95:
					var ai = coombaScene.duplicate()
					ai.transform.origin = Vector3(x, 0, y)
					root.add_child(ai)
