extends Spatial

export var wall_node_path : NodePath
export var speed : float = 6
export var upper_bound : float = 25
export var lower_bound : float = -25

var _wall_movement_direction : Vector3 = Vector3.ZERO
var _registered_players : Array
var _wall_node : Spatial
var _game_manager : Node

onready var _button_sprite_3d : Sprite3D = $MeshInstance/ButtonSprite3D as Sprite3D


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	_wall_node = get_node(wall_node_path) as Spatial
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("game_over", self, "on_game_over")


func _process(_delta : float) -> void:
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			_handle_player_input(player_string_prefix)


func _physics_process(delta : float) -> void:
	_handle_wall_movement(delta)


func _handle_player_input(prefix : String) -> void:
	if Input.is_action_pressed(prefix + "interact_up"):
		_wall_movement_direction.y = 1
	elif Input.is_action_pressed(prefix + "interact_down"):
		_wall_movement_direction.y = -1
	else:
		_wall_movement_direction.y = 0


func _handle_wall_movement(delta : float) -> void:
	if _wall_movement_direction.y != 0:
		_wall_node.translation += _wall_movement_direction * (speed * delta)
		
		if _wall_movement_direction.y == 1 and _wall_node.translation.y > upper_bound:
			_wall_node.translation.y = upper_bound
		elif _wall_movement_direction.y == -1 and _wall_node.translation.y < lower_bound:
			_wall_node.translation.y = lower_bound


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	_wall_movement_direction.y = 0
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false


func on_game_over() -> void:
	# TODO: finish function
	
	$InteractionArea.disconnect("body_entered", self, "on_player_registered")
	$InteractionArea.disconnect("body_exited", self, "on_player_unregistered")
	
	# Stop script
	set_script(null)
