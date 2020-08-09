extends Timer

class_name PlayerInteractions

var _caller: Node = null
var _callback: String = ""
var _binds := []

func _ready():
	one_shot = true
	connect("timeout", self, "_on_timeout")

func start_interaction(caller: Node, callback: String, length: float, binds: Array = []):
	if is_stopped():
		_caller = caller
		_callback = callback
		_binds = binds
		start(length)

func _on_timeout():
	_caller.callv(_callback, _binds)
	cancel()

func cancel():
	stop()
	_callback = ""
	_caller = null
	_binds = []
