extends RigidBody

export(NodePath) var linked_camera_path: NodePath
export(NodePath) var anim_player_path: NodePath

var _linked_camera: Camera
var _anim_player: AnimationPlayer
var _pitch_angle: float
var _pitch_axis: Vector3
var _yaw_angle: float
var _yaw_axis: Vector3
var _is_walking: bool

const PITCH_MAX_ANGLE: float = 89.0
const SPEED: float = 200.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_linked_camera = get_node(linked_camera_path)
	_anim_player = get_node(anim_player_path)
	_yaw_axis = Vector3.FORWARD
		
func _physics_process(delta):
	var dir: Vector3
	
	_linked_camera.look_at(
		global_transform.xform(_linked_camera.transform.origin + _pitch_axis),
		Vector3.UP)
		
	if Input.is_action_pressed("player_move_left"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("player_move_right"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("player_move_up"):
		dir += Vector3.BACK
	if Input.is_action_pressed("player_move_down"):
		dir += Vector3.FORWARD
	
	dir = dir.normalized()
	
	add_force(global_transform.xform(dir * SPEED) - global_transform.origin, Vector3.ZERO)
	
	if linear_velocity.length() > 0.1 and not _is_walking:
		_anim_player.play("walk_cam")
		_is_walking = true
	elif linear_velocity.length() <= 0.1 and _is_walking:
		_anim_player.play("idle_cam")
		_is_walking = false
		
	_anim_player.playback_speed = (linear_velocity.length() / SPEED) * 75.0
	
	dir = Vector3.ZERO
	
func _integrate_forces(state):
	look_at(transform.origin + _yaw_axis, Vector3.UP)
	
	if linear_velocity.length() > SPEED:
		linear_velocity = linear_velocity.normalized() * SPEED

func _input(event):
	if event is InputEventMouseMotion:
		_pitch_angle -= event.relative.y * 0.1
		
		if _pitch_angle < -PITCH_MAX_ANGLE:
			_pitch_angle = -PITCH_MAX_ANGLE
		elif _pitch_angle > PITCH_MAX_ANGLE:
			_pitch_angle = PITCH_MAX_ANGLE
			
		_yaw_angle += event.relative.x * 0.1
		
		if _yaw_angle < -180.0:
			_yaw_angle = _yaw_angle + 360.0
		elif _yaw_angle >= 180.0:
			_yaw_angle = _yaw_angle - 360.0
			
		_pitch_axis = Vector3(0, sin(deg2rad(_pitch_angle)), cos(deg2rad(_pitch_angle)))
		_yaw_axis = Vector3(cos(deg2rad(_yaw_angle)), 0, sin(deg2rad(_yaw_angle)))
