extends Spatial

export var MAX_SPEED : float = 25
export var ACCELERATION : float = 500

var s_w_bounds : Vector2
var n_e_bounds : Vector2

var velocity : Vector2

func _process(delta):
	handle_movement(delta)

#func _physics_process(delta):
#	handle_movement(delta)

func handle_movement(delta):
	# Rotation
	var look_direction = get_look_direction_input()
	
	if look_direction != Vector2.ZERO:
		look_direction = look_direction.normalized()
		var rotation_angle_rad = atan2(look_direction.y, look_direction.x)
		if abs(rotation_angle_rad) > 0.01:
			# Rotate smoothly to the target angle.
			rotation.z = lerp_angle(rotation.z, rotation_angle_rad, 0.25)
	
	# Translation
	var move_direction = get_move_direction_input()
	
	if move_direction != Vector2.ZERO:
		# Keep move_direction vector length in the range of [0, 1] 
		# for variable movement speed, based on how far the joystick is pressed.
		var move_direction_magnitude = move_direction.length_squared()
		if move_direction_magnitude > 1.0:
			move_direction = move_direction.normalized()
		
		velocity += move_direction * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED * move_direction_magnitude)
	else:
		# Decrease velocity gradually.
		velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
		
	# Manual AABB collision check for walls.
	if (translation.x <= s_w_bounds.x and velocity.x < 0.0 or
	translation.x >= n_e_bounds.x and velocity.x > 0.0):
		velocity.x = 0.0
	if (translation.y <= s_w_bounds.y and velocity.y < 0.0 or
	translation.y >= n_e_bounds.y and velocity.y > 0.0):
		velocity.y = 0.0
	
	translation += Vector3(velocity.x * delta, velocity.y * delta, 0.0)

func get_look_direction_input():
	# Player rotation input
	var look_direction = Vector2()
	
	if Input.is_action_pressed("player1_look_up") or Input.is_action_pressed("player1_look_down"):
		look_direction.y = Input.get_action_strength("player1_look_up") - Input.get_action_strength("player1_look_down")
	if Input.is_action_pressed("player1_look_left") or Input.is_action_pressed("player1_look_right"):
		look_direction.x = Input.get_action_strength("player1_look_right") - Input.get_action_strength("player1_look_left")
	
	return look_direction

func get_move_direction_input():
	# Player translation input
	var direction = Vector2()
	
	if Input.is_action_pressed("player1_move_up") or Input.is_action_pressed("player1_move_down"):
		direction.y = Input.get_action_strength("player1_move_up") - Input.get_action_strength("player1_move_down")
	if Input.is_action_pressed("player1_move_left") or Input.is_action_pressed("player1_move_right"):
		direction.x = Input.get_action_strength("player1_move_right") - Input.get_action_strength("player1_move_left")
	
	return direction
