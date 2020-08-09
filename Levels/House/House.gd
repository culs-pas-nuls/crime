extends Node

# Main script for the house level.

var playerScene = preload("res://Gameplay/Player/player.tscn").instance()

func _ready():
	generateLevel()

func generateLevel() -> void:
	var mapAssetPlacer = MapAssetPlacer.new()
	var mapGenerator = MapGenerator.new()
	var map = mapGenerator.generateNewMap()
	var spawnPoint = mapAssetPlacer.placeAssets(self, map)
	playerScene.transform.origin = spawnPoint
	add_child(playerScene)
