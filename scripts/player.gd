extends KinematicBody

export var MAX_SPEED : float = 15
export var ACCELERATION : float = 100

var velocity : Vector3
var player_input_prefix : String

func _ready():
	player_input_prefix = self.name.to_lower() + "_"

func _process(delta):
	handle_rotation()
	handle_movement(delta)

#func _physics_process(delta):
#	handle_movement(delta)

func handle_rotation():
	var look_direction = get_look_direction_input()
	
	if look_direction != Vector2.ZERO:
		look_direction = look_direction.normalized()
		var rotation_angle_rad = atan2(look_direction.y, look_direction.x)
		if abs(rotation_angle_rad) > 0.01:
			# Rotate smoothly to the target angle
			rotation.z = lerp_angle(rotation.z, rotation_angle_rad, 0.25)

func handle_movement(delta):
	var move_direction = get_move_direction_input()
	
	if move_direction.length() > 0.2:
		# Keep move_direction vector length in the range of [0, 1] 
		# for variable movement speed, based on how far the joystick is pressed
		var move_direction_magnitude = move_direction.length_squared()
		if move_direction_magnitude > 1.0:
			move_direction = move_direction.normalized()
		
#		velocity += move_direction * ACCELERATION * delta
#		velocity = velocity.clamped(MAX_SPEED * move_direction_magnitude)
		
		var acceleration_vector : Vector2 = move_direction * ACCELERATION * delta
		apply_movement(Vector3(acceleration_vector.x, acceleration_vector.y, 0), move_direction_magnitude)
	else:
		# Decrease velocity gradually
		velocity = velocity.linear_interpolate(Vector3.ZERO, 0.05)
#		apply_friction(0.5 * ACCELERATION * delta)
	
#	translation += Vector3(velocity.x * delta, velocity.y * delta, 0.0)
	velocity = move_and_slide(velocity)

func apply_movement(acceleration: Vector3, move_direction_magnitude : float):
	velocity += acceleration
	var clamped_velocity : Vector2 = Vector2(velocity.x, velocity.y).clamped(MAX_SPEED * move_direction_magnitude)
	velocity = Vector3(clamped_velocity.x, clamped_velocity.y, 0)

func apply_friction(deceleration: float):
	if velocity.length() > deceleration:
		velocity -= velocity.normalized() * deceleration
	else:
		velocity = Vector3.ZERO

func get_look_direction_input():
	# Player rotation input
	var look_direction = Vector2()
	
	if Input.is_action_pressed(player_input_prefix + "look_up") or Input.is_action_pressed(player_input_prefix + "look_down"):
		look_direction.y = Input.get_action_strength(player_input_prefix + "look_up") - Input.get_action_strength(player_input_prefix + "look_down")
	if Input.is_action_pressed(player_input_prefix + "look_left") or Input.is_action_pressed(player_input_prefix + "look_right"):
		look_direction.x = Input.get_action_strength(player_input_prefix + "look_right") - Input.get_action_strength(player_input_prefix + "look_left")
	
	return look_direction

func get_move_direction_input():
	# Player translation input
	var direction = Vector2()
	
	if Input.is_action_pressed(player_input_prefix + "move_up") or Input.is_action_pressed(player_input_prefix + "move_down"):
		direction.y = Input.get_action_strength(player_input_prefix + "move_up") - Input.get_action_strength(player_input_prefix + "move_down")
	if Input.is_action_pressed(player_input_prefix + "move_left") or Input.is_action_pressed(player_input_prefix + "move_right"):
		direction.x = Input.get_action_strength(player_input_prefix + "move_right") - Input.get_action_strength(player_input_prefix + "move_left")
	
	return direction
