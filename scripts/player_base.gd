extends Spatial

export var max_speed : float = 25
export var acceleration : float = 500
export var shooting_cooldown_time_ms = 1000

export var health : int = 10
export var attack_damage : int = 1

var s_w_bounds : Vector2
var n_e_bounds : Vector2
var ref_gun : Spatial

var velocity : Vector2
var last_shot_time : float = 0
var current_time : float = 1

func _process(delta):
	handle_movement(delta)
	handle_shooting()

#func _physics_process(delta):
#	handle_movement(delta)

func handle_movement(delta):
	# Rotation
	var look_direction = get_look_direction_input()
	
	if look_direction != Vector2.ZERO:
		look_direction = look_direction.normalized()
		var rotation_angle_rad = atan2(look_direction.y, look_direction.x)
		if abs(rotation_angle_rad) > 0.01:
			# Rotate smoothly to the target angle
			rotation.z = lerp_angle(rotation.z, rotation_angle_rad, 0.25)
	
	# Translation
	var move_direction = get_move_direction_input()
	
	if move_direction != Vector2.ZERO:
		# Keep move_direction vector length in the range of [0, 1] 
		# for variable movement speed, based on how far the joystick is pressed
		var move_direction_magnitude = move_direction.length_squared()
		if move_direction_magnitude > 1.0:
			move_direction = move_direction.normalized()
		
		velocity += move_direction * acceleration * delta
		velocity = velocity.clamped(max_speed * move_direction_magnitude)
	else:
		# Decrease velocity gradually
		velocity = velocity.linear_interpolate(Vector2.ZERO, 0.1)
		
	# Manual AABB collision check for walls
	if (translation.x <= s_w_bounds.x and velocity.x < 0.0 or
	translation.x >= n_e_bounds.x and velocity.x > 0.0):
		velocity.x = 0.0
	if (translation.y <= s_w_bounds.y and velocity.y < 0.0 or
	translation.y >= n_e_bounds.y and velocity.y > 0.0):
		velocity.y = 0.0
	
	translation += Vector3(velocity.x * delta, velocity.y * delta, 0.0)

func handle_shooting():
	current_time = OS.get_ticks_msec()
	
	if current_time - last_shot_time > shooting_cooldown_time_ms:
		if is_player_shooting():
			# Instance new bullet
			var shooting_direction = Vector2(transform.basis.x.x, transform.basis.x.y)
			var bullet = preload("res://scenes/bullet.tscn").instance()
			bullet.init(shooting_direction, attack_damage, self)
			get_parent().get_node("Bullets").add_child(bullet)
			bullet.translation = translation
			
			last_shot_time = current_time

func is_player_shooting():
	return Input.is_action_pressed("shoot")

func get_look_direction_input():
	# Player rotation input
	var look_direction = Vector2()
	
	if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
		look_direction.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	if Input.is_action_pressed("look_left") or Input.is_action_pressed("look_right"):
		look_direction.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	
	return look_direction

func get_move_direction_input():
	# Player translation input
	var direction = Vector2()
	
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		direction.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	return direction

func take_damage(damage_amount : int):
	health -= damage_amount
	print(self.to_string() + " took damage")
	if health <= 0:
		die()

func die():
	#TODO: remove player, add larger score bonus to player who defeated this one
	pass
