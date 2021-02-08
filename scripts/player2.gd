extends "res://scripts/player_base.gd"

func _ready():
	s_w_bounds.x = $"../Geometry/Player2_Bounds/S_W_Bounds".translation.x
	s_w_bounds.y = $"../Geometry/Player2_Bounds/S_W_Bounds".translation.y
	n_e_bounds.x = $"../Geometry/Player2_Bounds/N_E_Bounds".translation.x
	n_e_bounds.y = $"../Geometry/Player2_Bounds/N_E_Bounds".translation.y
	
	ref_gun = $Gun

func get_look_direction_input():
	# Player rotation input
	var look_direction = Vector2()
	
	if Input.is_action_pressed("player2_look_up") or Input.is_action_pressed("player2_look_down"):
		look_direction.y = Input.get_action_strength("player2_look_up") - Input.get_action_strength("player2_look_down")
	if Input.is_action_pressed("player2_look_left") or Input.is_action_pressed("player2_look_right"):
		look_direction.x = Input.get_action_strength("player2_look_right") - Input.get_action_strength("player2_look_left")
	
	return look_direction

func get_move_direction_input():
	# Player translation input
	var direction = Vector2()
	
	if Input.is_action_pressed("player2_move_up") or Input.is_action_pressed("player2_move_down"):
		direction.y = Input.get_action_strength("player2_move_up") - Input.get_action_strength("player2_move_down")
	if Input.is_action_pressed("player2_move_left") or Input.is_action_pressed("player2_move_right"):
		direction.x = Input.get_action_strength("player2_move_right") - Input.get_action_strength("player2_move_left")
	
	return direction

func is_player_shooting():
	return Input.is_action_pressed("player2_shoot")

func _to_string():
	return "Player 2"
