class_name ObjectGeneratorSettings

var props: Dictionary = {
	RoomType.Bathroom: weightedObjects([
		[10, ObjectInfo.new("Bathtub", Vector2(1, 2))],
		[3, ObjectInfo.new("Toilet", Vector2(1, 1))],
		[5, ObjectInfo.new("Sink", Vector2(1, 1))]
	]),
	RoomType.Bedroom: weightedObjects([
		[2, ObjectInfo.new("Bed", Vector2(2, 3))],
		[1, ObjectInfo.new("BedTall", Vector2(2, 3))],
		[4, ObjectInfo.new("Dresser", Vector2(1, 1))],
		[2, ObjectInfo.new("DresserTall", Vector2(1, 1))]
	]),
	RoomType.Kitchen: weightedObjects([
		[1, ObjectInfo.new("Fridge", Vector2(1, 1))],
		[1, ObjectInfo.new("Oven", Vector2(1, 1))],
		[10, ObjectInfo.new("Cabinet", Vector2(1, 1))]
	]),
	RoomType.Hallway: []
}

var object_max_allowed_modifier: float = 0.2
var object_min_generated: int = 1
var object_max_generated: int = 100


static func weightedObjects(objects: Array) -> Array:
	var array = []
	for data in objects:
		var weight = data[0]
		var objectInfo = data[1]
		for i in range(weight):
			array.append(objectInfo)
	return array
