extends Node

# Main script for the house level.

func _ready():
	generateLevel()

func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var mapGenerator = MapGenerator.new()
	var obj_generator = ObjectGenerator.new()
	var map_data_set = mapGenerator.generate_new_map()
	var objects: Array
	mapAssetPlacer.placeAssets(self, map_data_set.matrix)
	objects = obj_generator.generate_new_objects(map_data_set, ObjectGeneratorSettings.new(), self)
	
	
