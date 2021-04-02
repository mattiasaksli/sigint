extends Spatial

export var toggle_door_obstacle_path : NodePath
export var duration : float = 2

var _registered_players : Array
var _door_node : Spatial
var _open_point : Spatial
var _closed_point : Spatial
var _tween : Tween
var _can_play_animation : bool = true
var _game_manager : Node


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	var toggle_door_obstacle_path_string : String = ""
	for i in range(toggle_door_obstacle_path.get_name_count()):
		toggle_door_obstacle_path_string += toggle_door_obstacle_path.get_name(i) + "/"
	
	_door_node = get_node(toggle_door_obstacle_path_string + "Door") as Spatial
	_open_point = get_node(toggle_door_obstacle_path_string + "OpenPoint") as Spatial
	_closed_point = get_node(toggle_door_obstacle_path_string + "ClosedPoint") as Spatial
	_tween = get_node(toggle_door_obstacle_path_string + "Tween") as Tween
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("game_over", self, "on_game_over")


func _physics_process(_delta : float) -> void:
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			_handle_player_input(player_string_prefix)


func _handle_player_input(prefix : String) -> void:
	if _can_play_animation and Input.is_action_pressed(prefix + "interact_A"):
		_can_play_animation = false
		
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(
			_door_node,
			"translation",
			_closed_point.translation,
			_open_point.translation,
			duration, Tween.TRANS_BOUNCE,
			Tween.EASE_OUT
		)
		# warning-ignore:return_value_discarded
		_tween.start()


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")


func on_game_over() -> void:
	# TODO: finish function
	
	$InteractionArea.disconnect("body_entered", self, "on_player_registered")
	$InteractionArea.disconnect("body_exited", self, "on_player_unregistered")
	
	# Stop script
	set_script(null)
