extends "res://scripts/player_base.gd"

func _ready():
	s_w_bounds.x = $"../Geometry/Player3_Bounds/S_W_Bounds".translation.x
	s_w_bounds.y = $"../Geometry/Player3_Bounds/S_W_Bounds".translation.y
	n_e_bounds.x = $"../Geometry/Player3_Bounds/N_E_Bounds".translation.x
	n_e_bounds.y = $"../Geometry/Player3_Bounds/N_E_Bounds".translation.y

func get_look_direction_input():
	# Player rotation input
	var look_direction = Vector2()
	
	if Input.is_action_pressed("player3_look_up") or Input.is_action_pressed("player3_look_down"):
		look_direction.y = Input.get_action_strength("player3_look_up") - Input.get_action_strength("player3_look_down")
	if Input.is_action_pressed("player3_look_left") or Input.is_action_pressed("player3_look_right"):
		look_direction.x = Input.get_action_strength("player3_look_right") - Input.get_action_strength("player3_look_left")
	
	return look_direction

func get_move_direction_input():
	# Player translation input
	var direction = Vector2()
	
	if Input.is_action_pressed("player3_move_up") or Input.is_action_pressed("player3_move_down"):
		direction.y = Input.get_action_strength("player3_move_up") - Input.get_action_strength("player3_move_down")
	if Input.is_action_pressed("player3_move_left") or Input.is_action_pressed("player3_move_right"):
		direction.x = Input.get_action_strength("player3_move_right") - Input.get_action_strength("player3_move_left")
	
	return direction
