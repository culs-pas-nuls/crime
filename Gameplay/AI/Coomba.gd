extends RigidBody

const SPEED = 3
const max_stuck_time: float = 3.0
const min_fuel_time: float = 3.0
const max_fuel_time: float = 10.0

onready var _rayCast = get_node("RayCast")
onready var _ap = get_node("coomba/AnimationPlayer")

var _rnd = RandomNumberGenerator.new()
var _fuel: float = 0
var _path: Array
var _stuck_time: float
var _next_matrix_position: Vector2
var _target_position: Vector3

var __debug_target: CSGBox

func __setPurpose():
	var matrix_pos: Vector2
	
	matrix_pos = ProceduralHelper.to_matrix_position(transform.origin)
	_path = ProceduralHelper.path_finder.get_random_path_from_position(matrix_pos)
	_next_matrix_position = _path.pop_front()
	_target_position = ProceduralHelper.to_world_position(_next_matrix_position, 0)
	_fuel = _rnd.randi_range(min_fuel_time, max_fuel_time)


func _ready():
	__debug_target = CSGBox.new()
	__debug_target.width = 1
	__debug_target.height = 1
	__debug_target.depth = 1
	__debug_target.name = "pouet"
	get_parent().add_child(__debug_target)
	
	_rnd.randomize()
	_ap.get_animation("rumble").loop = true
	_ap.play("rumble", -1, 3)
	
func _integrate_forces(state):
	var dir: Vector3
	
	if ProceduralHelper.is_close_to_matrix_position(transform.origin, _next_matrix_position, 0.5):
		if _path.size() == 0:
			return
			
		_next_matrix_position = _path.pop_front()
		_target_position = ProceduralHelper.to_world_position(_next_matrix_position, 0)
		__debug_target.transform.origin = _target_position
		__debug_target.transform.origin.y = 1
	
	dir = (_target_position - transform.origin).normalized()
	linear_velocity = dir * SPEED
	look_at(transform.origin + dir, Vector3.UP)
	
func _physics_process(delta):
	if _fuel <= 0:
		__setPurpose()
		
	#_fuel -= delta

func _on_Coomba_body_entered(body: Node):
	#__setPurpose()
	pass
