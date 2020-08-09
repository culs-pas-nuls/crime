class_name PropsAssetPlacer

const __HALF_PI := PI * 0.5
const __UP := Vector3(0, 1, 0)

const PROP_NAME_LIST = [
	"Bed",
	"BedTall",
	"Dresser",
	"DresserTall",
	"Fridge",
	"Oven",
	"Microwave",
	"Television",
	"TelevisionStand",
	"Cabinet",
	"Sink",
	"Toilet",
	"Lamp",
	"Bathtub",
	"ToiletPaper"
]

var __props := {}


func _init() -> void:
	var propsLibrary := preload("res://Assets/Props/PropsLibrary.tscn").instance()
	for name in PROP_NAME_LIST:
		__props[name] = propsLibrary.get_node(name)


func placeProps(root: Node, objects: Array) -> void:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	for object in objects:
		var objectInfo: ObjectInfo = object
		var prop = spawnProp(
			root,
			objectInfo.name,
			Vector3(objectInfo.position.x, 0, objectInfo.position.y),
			-1)
		prop.transform.origin.x += objectInfo.size.x - 1
		prop.transform.origin.z += objectInfo.size.y - 1


func spawnProp(root: Node, prop_name: String, position: Vector3, orientation: int) -> Spatial:
	var prop = __props[prop_name].duplicate()
	prop.transform.origin = position
	prop.rotate(__UP, __HALF_PI * orientation)
	root.add_child(prop)
	return prop
