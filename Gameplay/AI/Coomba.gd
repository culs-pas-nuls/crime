extends RigidBody

const SPEED = 1

onready var _rayCast = get_node("RayCast")
onready var _ap = get_node("coomba/AnimationPlayer")

var _rnd = RandomNumberGenerator.new()
var _movement = Vector3(0, 0, 0)
var _fuel = 0


func __setPurpose():
	_movement = Vector3(
		_rnd.randi_range(-1, 1),
		0,
		_rnd.randi_range(-1, 1)
	).normalized()
	_fuel = _rnd.randi_range(0, 1000)
	look_at(transform.origin + _movement, Vector3.UP)


func _ready():
	_rnd.randomize()
	_ap.get_animation("rumble").loop = true
	_ap.play("rumble", -1, 3)


func _process(_a):
	if _fuel < 0:
		__setPurpose()
	linear_velocity = _movement * SPEED
	_fuel -= 1


func _on_Coomba_body_entered(body: Node):
	__setPurpose()
