extends Node

# Main script for the house level.

var playerScene = preload("res://Gameplay/Player/player.tscn").instance()
var doomPlayerScene = preload("res://Gameplay/DoomPlayer/DoomPlayer.tscn").instance()
var coombaScene = preload("res://Gameplay/AI/Coomba.tscn").instance()


func _ready():
	generateLevel()


func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var propsAssetPlacer = PropsAssetPlacer.new()
	
	ProceduralHelper.map_generator.generate_new_map()
	var spawnPoint = mapAssetPlacer.placeAssets(self, ProceduralHelper.map_generator.data_set.matrix)
	
	ProceduralHelper.object_generator.generate_new_objects()
	propsAssetPlacer.placeProps(self, ProceduralHelper.object_generator.data_set.objects)
	
	ProceduralHelper.path_finder.reset()
	
	__placeAi(self, ProceduralHelper.map_generator.data_set.matrix)
	doomPlayerScene.transform.origin = spawnPoint
	add_child(doomPlayerScene)


func __placeAi(root: Node, map: Array) -> void:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	for y in range(map.size()):
		var sub = map[y]
		for x in range(sub.size()):
			var tileInfo = sub[x]
			if ProceduralHelper.is_tile_walkable(Vector2(x, y)) and rnd.randf() > .95:
					var ai = coombaScene.duplicate()
					ai.transform.origin = Vector3(x, 0, y)
					root.add_child(ai)
