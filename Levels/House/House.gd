extends Node

# Main script for the house level.

func _ready():
	generateLevel()

func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var mapGenerator = MapGenerator.new()
	var map = mapGenerator.generateNewMap()
	mapAssetPlacer.placeAssets(self, map)
