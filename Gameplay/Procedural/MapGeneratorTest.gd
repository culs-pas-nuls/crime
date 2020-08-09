extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var map_generator: MapGenerator
	var obj_generator: ObjectGenerator
	var map_gen_data_set: MapGeneratorDataSet
	
	map_generator = MapGenerator.new()
	map_gen_data_set = map_generator.generate_new_map(self)
	
	obj_generator = ObjectGenerator.new()
	obj_generator.generate_new_objects(map_gen_data_set)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
