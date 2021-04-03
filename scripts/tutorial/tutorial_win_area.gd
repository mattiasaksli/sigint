extends Area

signal first_player_entered_win_area
signal all_players_entered_win_area
signal end_tutorial

export var main_menu_path : String

var _players_in_win_area : Dictionary
var _level_loader_thread : LevelLoader
# The game manager does not handle level loading in the tutorial
var _game_manager : Node

var _first_player_entered_win_area : bool = false
var _is_tween_paused : bool = false

onready var _timer : Timer = $Timer as Timer
onready var _tween : Tween = $Tween as Tween
onready var _goal_progress_bar : TextureProgress = $GoalBar/Viewport/GoalProgressBar as TextureProgress
onready var _tutorial_control : Control = $"/root/Main/TutorialControl" as Control


func _enter_tree():
	# Set up signals for the current level
	_game_manager = $"/root/Main/GameManager"
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("add_player", self, "new_player_spawned")
	# warning-ignore:return_value_discarded
	_game_manager.connect("remove_player", self, "player_despawned")


func _ready() -> void:
	_level_loader_thread = preload("res://scripts/level_loader.gd").new()
	_level_loader_thread.start()
	
	# warning-ignore:return_value_discarded
	self.connect("first_player_entered_win_area", _tutorial_control, "on_first_player_entered_win_area")
	# warning-ignore:return_value_discarded
	self.connect("all_players_entered_win_area", _tutorial_control, "on_all_players_entered_win_area")
	# warning-ignore:return_value_discarded
	self.connect("end_tutorial", _tutorial_control, "on_tutorial_end")
	# warning-ignore:return_value_discarded
	_tutorial_control.connect("load_main_menu", self, "on_switch_tutorial_for_main_menu")


func on_player_entered(body: Node) -> void:
	if not _first_player_entered_win_area:
		_first_player_entered_win_area = true
		emit_signal("first_player_entered_win_area")
	
	_players_in_win_area[body] = true
	
	if _are_all_players_in_win_area():
		_start_loading_main_menu()


func on_player_exited(body: Node) -> void:
	if body in _players_in_win_area:
		# Happens if the player is not despawned
		_players_in_win_area[body] = false
	
	# Not all players are in the win area, stopping timer and level loading
	if not _timer.is_stopped():
		_stop_loading_main_menu()


func on_progress_bar_full() -> void:
	# Cannot refer to _game_manager by static type due to Godot parser bug
	# warning-ignore:unsafe_property_access
	_game_manager._can_handle_joystick_connections = false
	
	emit_signal("end_tutorial")


func on_switch_tutorial_for_main_menu() -> void:
	# Swaps old Root3D node for the newly loaded one
	var next_scene : Control = _level_loader_thread.get_level(main_menu_path).instance()
	_level_loader_thread.stop_thread()
	
	$"/root/Main".queue_free()
	$"/root".add_child(next_scene)


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


func _start_loading_main_menu() -> void:
	emit_signal("all_players_entered_win_area")
	
	if _is_tween_paused:
		# Resumes interpolating the progress bar
		
		# warning-ignore:return_value_discarded
		_tween.resume(_goal_progress_bar, "value")
	else:
		# Starts interpolating the progress bar
		
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(_goal_progress_bar, "value", 0, 100, _timer.wait_time)
		# warning-ignore:return_value_discarded
		_tween.start()
	
	_level_loader_thread.queue_level(main_menu_path)
	_timer.start()


func _stop_loading_main_menu() -> void:
	_timer.stop()
	
	# Stop interpolating the progress bar
	# warning-ignore:return_value_discarded
	_tween.stop(_goal_progress_bar, "value")
	# warning-ignore:return_value_discarded
	_tween.reset(_goal_progress_bar, "value")
	
	_level_loader_thread.cancel_loading_level()
