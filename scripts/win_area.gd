extends Area

signal level_loaded

export var next_level_path : String

var _players_in_win_area : Dictionary
var _level_loader_thread : LevelLoader
var _game_manager : Node

onready var _timer : Timer = $Timer


func _ready() -> void:
	_level_loader_thread = preload("res://scripts/level_loader.gd").new()
	_level_loader_thread.start()
	
	# Set up signal for the current level
	_game_manager = $"/root/GameManager"
	# warning-ignore:return_value_discarded
	self.connect("level_loaded", _game_manager, "on_new_level_loaded")


func on_player_entered(body: Node) -> void:
	_update_players()
	_players_in_win_area[body] = true
	
	if _are_all_players_in_win_area():
		_win()


func on_player_exited(body: Node) -> void:
	_update_players()
	_players_in_win_area[body] = false
	
	# Not all players are in the win area, stopping timer and level loading
	if not _timer.is_stopped():
		_timer.stop()
		_level_loader_thread.cancel_loading_level()


func on_timer_timeout():
	# Cannot refer by static type due to parser bug
	# warning-ignore:unsafe_property_access
	_game_manager._can_handle_joystick_connections = false
	
	var next_scene : PackedScene = _level_loader_thread.get_level(next_level_path)
	$"/root/Root3D".queue_free()
	$"/root".add_child(next_scene.instance())
	
	emit_signal("level_loaded")


func _update_players():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if not _players_in_win_area.has(player):
			_players_in_win_area[player] = false
			print_debug("Win area started tracking " + player.name)


func _are_all_players_in_win_area() -> bool:
	for is_present in _players_in_win_area.values():
		if not is_present:
			return false
	
	return true


func _win() -> void:
	_level_loader_thread.queue_level(next_level_path)
	_timer.start()
