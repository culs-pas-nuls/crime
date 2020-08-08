extends KinematicBody

enum State {IDLE,PATROL,CHASE,ATTACK,LOSE}
var _state

# Rename targets with a number so that it makes the order of the patrols

var path = []
var path_ind = 0
export (int) var move_speed = 5
onready var nav = get_parent()
var motion = Vector3.ZERO

var patrol_points
var patrol_i = 0

var player


func _ready():
	add_to_group("patrol")
	
	if get_tree().has_group("patrol_points"):
		patrol_points = get_tree().get_nodes_in_group("patrol_points")
	
	anim_move()
	_state = State.IDLE
	

func _process(_delta):
	pass



func _physics_process(_delta):
	if _state == State.IDLE:
		patrol()
	if _state == State.CHASE:
		chase()
	if _state == State.PATROL:
		_move()



func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

func _move():
	if path_ind < path.size():
		var move_vec = (path[path_ind] - global_transform.origin)
		if move_vec.length() < 0.1:
			path_ind += 1
		else:
			motion = move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
			look_at(path[path_ind], Vector3(0, 1, 0))
	else:
		if _state == State.PATROL:
			_state = State.IDLE


func patrol():
	_state = State.PATROL
	if patrol_i == patrol_points.size():
		patrol_i = 0
	
	var _target_origin = patrol_points[patrol_i].global_transform.origin
	move_to(_target_origin)
	patrol_i += 1


func chase():
	_state = State.CHASE
	var _player_origin = player.global_transform.origin
	var _direction = _player_origin - global_transform.origin
	look_at(_player_origin, Vector3.UP)
	move_and_slide(_direction.normalized() * move_speed, Vector3(0, 1, 0))
	
	GM.call_the_police()

# Detection scripts


func _on_Vision_body_entered(body):
	if body.name == "Player" && _state == State.PATROL:
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(global_transform.origin, body.global_transform.origin)
		
		var collider = result["collider"].name

		if collider == null:
			printerr(collider, "Collider null")
			return
		if collider == "Player":
			player = body
			_state = State.CHASE


#Animations
func anim_move():
	$coomba/AnimationPlayer.get_animation("rumble").loop = true
	$coomba/AnimationPlayer.play("rumble")

func anim_attack():
	$coomba/AnimationPlayer.play("attack")


func _on_AttackArea_body_entered(body):
	if body.name == "Player":
		_state = State.ATTACK
		GM.game_over()
