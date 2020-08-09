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

const __TMP_LOGO: StreamTexture = preload("res://icon.png")
const __TMP_CONTENT_NAME: String = "Content"

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
	__init_prop(prop, prop_name)
	prop.transform.origin = position
	prop.rotate(__UP, __HALF_PI * orientation)
	root.add_child(prop)
	return prop


func __init_prop(prop: Node, prop_name: String):
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()

	var prop_data = {}
	if prop is PickableProp:
		prop_data["logo"] = __TMP_LOGO
		prop_data["name"] = prop_name
		if prop is InteractableProp:
			prop_data["content_logo"] = __TMP_LOGO
			prop_data["content_name"] = __TMP_CONTENT_NAME
			prop_data["length"] = 2
	prop.init(prop_data)
