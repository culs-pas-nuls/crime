extends Node

# Main script for the house level.

var playerScene = preload("res://Gameplay/Player/player.tscn").instance()


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
	playerScene.transform.origin = spawnPoint
	add_child(playerScene)
