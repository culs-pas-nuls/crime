class_name Item

var _LOGO: StreamTexture = null
var _NAME: String = ""


func _init(logo: StreamTexture, name: String):
	_LOGO = logo
	_NAME = name


func get_item_logo():
	return _LOGO


func get_item_name():
	return _NAME
