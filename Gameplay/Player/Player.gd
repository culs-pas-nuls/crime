extends RigidBody

class_name Player

const DroppedItemScn = preload("res://Assets/DroppedItem/DroppedItem.tscn")

const WALK_SPEED: float = 7.0
const SPRINT_MULT: float = 2.0
const DROP_FORCE: float = 8.0

var dir: Vector3 = Vector3()
var sprinting := false
var moving := false

onready var animation_handler: AnimationHandler = $AnimationHandler
onready var rotation_helper: Spatial = $RotationHelper
onready var raycast: RayCast = $RotationHelper/RayCast
onready var inventory = $Inventory


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	animation_handler.animator = get_node("RotationHelper/character/AnimationPlayer")
	inventory.init(12)
	inventory.hide()
	inventory.connect("on_InventoryItem_click", self, "_on_InventoryItem_click")


func _process(_delta: float):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	_process_inventory(_delta)


func _physics_process(delta : float):
	_process_movements(delta)
	_process_interactions(delta)


func _process_movements(_delta : float):
	var speed := WALK_SPEED
	dir = Vector3(0, 0, 0)
	sprinting = false
	moving = false

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
		sprinting = true

	if dir:
		rotation_helper.set_orientation(dir)
		# Waking up the physics when movement occurs
		moving = true
		sleeping = false

	dir = dir.normalized()
	dir.z *= speed
	dir.x *= speed
	animation_handler.progress_animation_stance(moving, sprinting)


func _integrate_forces(body: PhysicsDirectBodyState) -> void:
	body.linear_velocity = self.to_global(dir) - global_transform.origin


func _process_interactions(_delta: float):
	if Input.is_action_just_pressed("player_interact"):
		raycast.enabled = true
		_drop_item(null)

	elif Input.is_action_just_released("player_interact"):
		raycast.enabled = false

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print("hit ", collider)


func _process_inventory(_delta: float):
	if Input.is_action_just_pressed("open_inventory"):
		if inventory.visible:
			inventory.hide()
		else:
			inventory.show()


func _on_InventoryItem_click(inventory_item: InventoryItem):
	var item = inventory_item.get_item()
	var removed = inventory.remove_item(inventory_item)
	if not removed: return

	_drop_item(item)


func _drop_item(item: Node):
	var dropped_item = DroppedItemScn.instance()
	dropped_item.transform.origin = transform.origin
	dropped_item.set_item(item)
	# The actual "front" is -Z
	dropped_item.apply_central_impulse(-rotation_helper.transform.basis.z * DROP_FORCE)
	get_tree().get_root().add_child(dropped_item)
