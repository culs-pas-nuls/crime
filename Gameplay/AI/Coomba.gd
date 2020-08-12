extends RigidBody

const SPEED = 3
const MAX_STUCK_TIME: float = 3.0
const MIN_FUEL_TIME: float = 3.0
const MAX_FUEL_TIME: float = 10.0
const __DEBUG_ENABLED: bool = false

onready var _rayCast = get_node("RayCast")
onready var _ap = get_node("coomba/AnimationPlayer")

var _rnd = RandomNumberGenerator.new()
var _fuel: float = 0
var _path: Array
var _stuck_time: float
var _previous_matrix_position: Vector2
var _current_matrix_position: Vector2
var _next_matrix_position: Vector2
var _target_position: Vector3
var _last_valid_matrix_position: Vector2
var _dir: Vector3
var __debug_target: CSGBox

func __setPurpose():
	var matrix_pos: Vector2
	
	# Get the closest tile from our position
	matrix_pos = ProceduralHelper.find_closest_walkable_tile_position(transform.origin)
	
	# None found for some reason...
	if matrix_pos.x == -1:
		# Start from the last valid position
		matrix_pos = _last_valid_matrix_position
	
	# Generate a new path
	_path = ProceduralHelper.path_finder.get_random_path_from_position(matrix_pos)
	
	# No path found...
	if _path == null:
		# Fallback with a shitty path
		_path = [matrix_pos]
	
	_next_matrix_position = _path.pop_front()
	_last_valid_matrix_position = _next_matrix_position
	_target_position = ProceduralHelper.to_world_position(_next_matrix_position, 0)
	_fuel = _rnd.randi_range(MIN_FUEL_TIME, MAX_FUEL_TIME)


func _ready():
	if __DEBUG_ENABLED:
		__debug_create_cube()
	
	_rnd.randomize()
	_ap.get_animation("rumble").loop = true
	_ap.play("rumble", -1, 3)
	

func _integrate_forces(state):
	# Slow down if the coomba is too fast
	if linear_velocity.length() > SPEED:
		linear_velocity = linear_velocity.normalized() * SPEED
	
	# Override the physics rotation
	if _dir != Vector3.ZERO:
		look_at(transform.origin + _dir, Vector3.UP)	
	
	
func _physics_process(delta):
	if _fuel <= 0:
		__setPurpose()
		_stuck_time = 0
		
	_fuel -= delta
	
	_current_matrix_position = ProceduralHelper.to_matrix_position(transform.origin)
	
	# It seems the coomba is stuck...
	if _current_matrix_position == _previous_matrix_position:
		# Increment the stuck timer
		_stuck_time += get_physics_process_delta_time()
	else:
		_stuck_time = 0
	
	# Was stuck for too long
	if 	_stuck_time >= MAX_STUCK_TIME:
		# Find a new purpose
		__setPurpose()
		_stuck_time = 0
		return
	
	# If we reach the next tile
	if ProceduralHelper.is_close_to_matrix_position(transform.origin, _next_matrix_position, 0.5):
		# Stop if this is the path end
		if _path.size() == 0:
			return
		
		# Update the last valid position
		_last_valid_matrix_position = _next_matrix_position
		# Set the next tile
		_next_matrix_position = _path.pop_front()
		# Convert it to world position
		_target_position = ProceduralHelper.to_world_position(_next_matrix_position, 0)
		
		if __DEBUG_ENABLED:
			__debug_target.transform.origin = _target_position
			__debug_target.transform.origin.y = 1
	
	# Add force
	_dir = (_target_position - transform.origin).normalized()
	add_force(_dir * SPEED, Vector3.ZERO)

func _on_Coomba_body_entered(body: Node):
	#__setPurpose()
	pass

func __debug_create_cube() -> void:
	__debug_target = CSGBox.new()
	__debug_target.width = 1
	__debug_target.height = 1
	__debug_target.depth = 1
	__debug_target.name = "pouet"
	get_parent().add_child(__debug_target)
