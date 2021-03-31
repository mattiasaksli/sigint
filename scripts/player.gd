class_name Player

extends KinematicBody

export var max_speed : float = 15
export var acceleration : float = 100

var _game_manager : Node
var _velocity : Vector3
var _player_input_prefix : String


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	_player_input_prefix = self.name.to_lower() + "_"
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("game_over", self, "on_game_over")


#func _process(delta):
#	_handle_movement(delta)


func _physics_process(delta : float) -> void:
	_handle_movement(delta)


func move_on_bridge(amount : Vector3) -> void:
	# Amount is already multiplied by delta time
	translation += amount


func _handle_movement(delta : float) -> void:
	var move_direction : Vector2 = _get_move_direction_input()
	
	if move_direction.length() > 0.2:
		# Keep move_direction vector length in the range of [0, 1] 
		# for variable movement speed, based on how far the joystick is pressed
		var move_direction_magnitude : float = move_direction.length_squared()
		if move_direction_magnitude > 1.0:
			move_direction = move_direction.normalized()
		
#		_velocity += move_direction * acceleration * delta
#		_velocity = _velocity.clamped(max_speed * move_direction_magnitude)
		
		var acceleration_vector : Vector2 = move_direction * (acceleration * delta)
		_apply_movement(Vector3(acceleration_vector.x, acceleration_vector.y, 0), move_direction_magnitude)
	else:
		# Decrease _velocity gradually
		_velocity = _velocity.linear_interpolate(Vector3.ZERO, 0.05)
#		_apply_friction(0.5 * acceleration * delta)
	
#	translation += Vector3(_velocity.x * delta, _velocity.y * delta, 0.0)
	_velocity = move_and_slide(_velocity)


func _apply_movement(accel: Vector3, move_direction_magnitude : float) -> void:
	_velocity += accel
	var clamped_velocity : Vector2 = Vector2(_velocity.x, _velocity.y).clamped(max_speed * move_direction_magnitude)
	_velocity = Vector3(clamped_velocity.x, clamped_velocity.y, 0)


func _apply_friction(deceleration: float) -> void:
	if _velocity.length() > deceleration:
		_velocity -= _velocity.normalized() * deceleration
	else:
		_velocity = Vector3.ZERO


func _get_move_direction_input() -> Vector2:
	# Player translation input
	var direction : Vector2 = Vector2()
	
	if Input.is_action_pressed(_player_input_prefix + "move_up") or Input.is_action_pressed(_player_input_prefix + "move_down"):
		direction.y = Input.get_action_strength(_player_input_prefix + "move_up") - Input.get_action_strength(_player_input_prefix + "move_down")
	if Input.is_action_pressed(_player_input_prefix + "move_left") or Input.is_action_pressed(_player_input_prefix + "move_right"):
		direction.x = Input.get_action_strength(_player_input_prefix + "move_right") - Input.get_action_strength(_player_input_prefix + "move_left")
	
	return direction


func on_game_over() -> void:
	# TODO: finish function
	
	# Stop script
	set_script(null)
