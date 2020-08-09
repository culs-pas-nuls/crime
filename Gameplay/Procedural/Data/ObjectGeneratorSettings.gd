class_name ObjectGeneratorSettings

var props: Dictionary = {
	RoomType.Bathroom: [
		ObjectInfo.new("bathtub", Vector2(2, 1))
	],
	RoomType.Bedroom: [
		ObjectInfo.new("bed", Vector2(2, 1))
	],
	RoomType.Kitchen: [
		ObjectInfo.new("fridge", Vector2(1, 1))
	],
	RoomType.Hallway: [
		ObjectInfo.new("vase", Vector2(1, 1)),
		ObjectInfo.new("plant", Vector2(1, 1))
	]
}

var object_max_allowed_modifier: float = 0.2
var object_min_generated: int = 1
var object_max_generated: int = 100
