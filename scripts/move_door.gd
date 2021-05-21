extends Spatial

enum DoorSide {LEFT_DOOR, RIGHT_DOOR}

export(DoorSide) var side
export var double_doors_obstacle_path : NodePath
export var speed : float = 3
export var closed_bound : float = 19.5
export var open_bound : float = 10

var _door_movement_direction : Vector3 = Vector3.ZERO
var _registered_players : Array
var _door_node : Spatial
var _game_manager : Node

onready var _button_sprite_3d : Sprite3D = $ButtonSprite3D as Sprite3D


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	var actual_door_path : String = ""
	for i in range(double_doors_obstacle_path.get_name_count()):
		actual_door_path += double_doors_obstacle_path.get_name(i) + "/"
	
	if side == DoorSide.LEFT_DOOR:
		actual_door_path += "Left/Door"
	elif side == DoorSide.RIGHT_DOOR:
		actual_door_path += "Right/Door"
	
	_door_node = get_node(actual_door_path) as Spatial
	
	_game_manager.connect("game_over", self, "on_game_over")


func _physics_process(delta : float) -> void:
	_handle_door_movement(delta)
	
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			_handle_player_input(player_string_prefix)


func _handle_player_input(prefix : String) -> void:
	if Input.is_action_pressed(prefix + "interact_A"):
		if _door_node.translation.x > open_bound:
			_door_movement_direction.x = -1
		else:
			_door_movement_direction.x = 0
	else:
		if _door_node.translation.x < closed_bound:
			_door_movement_direction.x = 1
		else:
			_door_movement_direction.x = 0


func _handle_door_movement(delta : float) -> void:
	if _door_movement_direction.x != 0:
		if _door_movement_direction.x == -1 and _door_node.translation.x < open_bound:
			# Door is fully opened
			_door_node.translation.x = open_bound
		elif _door_movement_direction.x == 1 and _door_node.translation.x > closed_bound:
			# Door is fully closed
			_door_node.translation.x = closed_bound
		else:
			_door_node.translation += _door_movement_direction * (speed * delta)


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	if _door_node.translation.x < closed_bound:
		_door_movement_direction.x = 1
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false


func on_game_over() -> void:
	# TODO: finish function
	
	$InteractionArea.disconnect("body_entered", self, "on_player_registered")
	$InteractionArea.disconnect("body_exited", self, "on_player_unregistered")
	
	# Stop script
	set_script(null)

