extends RigidBody

class_name Player

const WALK_SPEED: float = 7.0
const SPRINT_MULT: float = 2.0

var dir: Vector3 = Vector3()
onready var rotation_helper: Spatial = $RotationHelper
onready var animator: AnimationPlayer = get_node("RotationHelper/character/AnimationPlayer")

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float):
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()

func _physics_process(delta : float):
    process_movements(delta)

func process_movements(_delta : float):
    var speed: float = WALK_SPEED

    dir = Vector3(0, 0, 0)
    if Input.is_action_pressed("player_move_left"):
        dir.z -= 1
    if Input.is_action_pressed("player_move_right"):
        dir.z += 1
    if Input.is_action_pressed("player_move_up"):
        dir.x += 1
    if Input.is_action_pressed("player_move_down"):
        dir.x -= 1

    if Input.is_action_pressed("player_sprint"):
        speed *= SPRINT_MULT

    dir = dir.normalized()
    dir.z *= speed
    dir.x *= speed

    # Waking up the physics when movement occurs
    if dir:
        rotation_helper.set_orientation(dir)
        sleeping = false

func _integrate_forces(body: PhysicsDirectBodyState) -> void:
    body.linear_velocity = self.to_global(dir) - global_transform.origin
