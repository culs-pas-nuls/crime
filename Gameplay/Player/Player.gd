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
onready var interact_progress: ProgressBar = $HUD/InteractProgress
onready var rotation_helper: Spatial = $RotationHelper
onready var raycast: RayCast = $RotationHelper/RayCast
onready var interactions = $PlayerInteractions
onready var inventory = $HUD/Inventory


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	animation_handler.animator = get_node("RotationHelper/character/AnimationPlayer")
	__init_hud()


func __init_hud():
	inventory.init(6)
	inventory.hide()
	inventory.connect("on_InventoryItem_click", self, "_on_InventoryItem_click")

	interact_progress.value = 0
	interact_progress.hide()

func _process(_delta: float):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	_process_inventory(_delta)
	_process_interactions(_delta)


func _physics_process(delta : float):
	_process_movements(delta)


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
		if raycast.is_colliding():
			_interact_with_item(raycast.get_collider())
	elif Input.is_action_just_released("player_interact"):
		_cancel_interaction()
	elif Input.is_action_pressed("player_interact"):
		if (not interactions.is_stopped()):
			var remaining = interactions.time_left / interactions.wait_time
			interact_progress.value = 1 - remaining
		if (linear_velocity.length_squared() >= 1):
			_cancel_interaction()
	elif Input.is_action_just_pressed("player_pick_up"):
		if raycast.is_colliding():
			_pick_up_item(raycast.get_collider())


func _process_inventory(_delta: float):
	if Input.is_action_just_pressed("open_inventory"):
		if inventory.visible:
			inventory.hide()
		else:
			inventory.show()


func _on_InventoryItem_click(inventory_item: InventoryItem):
	var item = inventory_item.get_item()
	var removed = inventory.remove_item(inventory_item)
	if not removed:
		return
	_drop_item(item)


func _drop_item(item: Node):
	var dropped_item: DroppedItem = DroppedItemScn.instance()
	dropped_item.transform.origin = transform.origin
	dropped_item.set_item(item)
	# The actual "front" is -Z
	dropped_item.apply_central_impulse(-rotation_helper.transform.basis.z * DROP_FORCE)
	get_tree().get_root().add_child(dropped_item)


func _pick_up_item(collider: Node):
	if collider.has_method("pick_up"):
		var item = collider.get_item()
		var added = inventory.add_item(item)
		if added:
			collider.pick_up()


func _interact_with_item(collider: Node):
	if collider.has_method("get_interaction_length"):
		var length: float = collider.get_interaction_length()
		interactions.start_interaction(self, "_on_interaction_done", length, [collider])
		interact_progress.value = 0
		interact_progress.show()


func _cancel_interaction():
	interactions.cancel()
	interact_progress.value = 0
	interact_progress.hide()


func _on_interaction_done(collider: Node):
	_cancel_interaction()
	collider.interact()
