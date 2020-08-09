extends Camera

# Throw-away script, for moving the camera around.

const __SPEED = 0.5


func _physics_process(_delta: float):
	var dir = Vector3(0, 0, 0)
	if Input.is_action_pressed("player_move_left"):
		dir.x += 1
		dir.z -= 1
	if Input.is_action_pressed("player_move_right"):
		dir.x -= 1
		dir.z += 1
	if Input.is_action_pressed("player_move_up"):
		dir.x += 1
		dir.z += 1
	if Input.is_action_pressed("player_move_down"):
		dir.x -= 1
		dir.z -= 1
	dir = dir.normalized()
	dir.x *= __SPEED
	dir.z *= __SPEED
	self.transform.origin = self.transform.origin + dir
