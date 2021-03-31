extends Area

signal level_loaded

export var next_level_path : String

var _players_in_win_area : Dictionary
var _level_loader_thread : LevelLoader
var _game_manager : Node

onready var _timer : Timer = $Timer


func _enter_tree():
	# Set up signal for the current level
	_game_manager = $"/root/Main/GameManager"
	# warning-ignore:return_value_discarded
	_game_manager.connect("add_player", self, "new_player_spawned")
	# warning-ignore:return_value_discarded
	_game_manager.connect("remove_player", self, "player_despawned")
	# warning-ignore:return_value_discarded
	self.connect("level_loaded", _game_manager, "on_new_level_loaded")


func _ready() -> void:
	_level_loader_thread = preload("res://scripts/level_loader.gd").new()
	_level_loader_thread.start()


func on_player_entered(body: Node) -> void:
	_players_in_win_area[body] = true
	
	if _are_all_players_in_win_area():
		_start_loading_level()


func on_player_exited(body: Node) -> void:
	if body in _players_in_win_area:
		# Happens if the player is not despawned
		_players_in_win_area[body] = false
	
	# Not all players are in the win area, stopping timer and level loading
	if not _timer.is_stopped():
		_timer.stop()
		_level_loader_thread.cancel_loading_level()


func on_timer_timeout():
	# Cannot refer to _game_manager by static type due to Godot parser bug
	# warning-ignore:unsafe_property_access
	_game_manager._can_handle_joystick_connections = false
	
	# Swaps old Root3D node for the newly loaded one
	var next_scene : Spatial = _level_loader_thread.get_level(next_level_path).instance()
	_level_loader_thread.stop_thread()
	
	$"/root/Main/Root3D".queue_free()
	$"/root/Main".add_child(next_scene)
	
	emit_signal("level_loaded")


func new_player_spawned(new_player : Node):
	# New player spawned at spawn location
	_players_in_win_area[new_player] = false


func player_despawned(old_player : Node):
	# Player despawned, on_player_exited() will handle stopping the timer
	
	if old_player in _players_in_win_area:
		# Deletes the player from list, if the node has not been deleted yet
		# warning-ignore:return_value_discarded
		_players_in_win_area.erase(old_player)
	else:
		# The node has already been removed from the scene, deletes the null ref player from the dictionary
		for player in _players_in_win_area:
			if player == null:
				# warning-ignore:return_value_discarded
				_players_in_win_area.erase(player)


func _are_all_players_in_win_area() -> bool:
	for is_present in _players_in_win_area.values():
		if not is_present:
			return false
	
	return true


func _start_loading_level() -> void:
	print("Started loading new level")
	
	_level_loader_thread.queue_level(next_level_path)
	_timer.start()
