class_name GameManager

extends Node

signal add_player(player)
signal remove_player(player)
signal enable_player_input
signal game_over
signal can_pause_enabled
signal can_pause_disabled

# The current level is always at index 0
const LEVELS_STACK : Array = [
	"res://scenes/levels/level1.tscn",
	"res://scenes/levels/level2.tscn",
	"res://scenes/levels/level3.tscn"
]
const MAIN_MENU_PATH : String = "res://scenes/menus/main_menu.tscn"

var _new_player_spawn_locations : Array

var _controller_player_dict : Dictionary
var _can_handle_joystick_connections : bool = true    # Is set to false while the level is changing
var _unhandled_joystick_connections : Dictionary

var _level_loader_thread : LevelLoader


func _ready() -> void:
	Input.connect("joy_connection_changed", self, "on_controller_connection_changed")
	
	self.connect("can_pause_enabled", $"/root/Main/PauseMenuControl", "on_pause_enabled")
	self.connect("can_pause_disabled", $"/root/Main/PauseMenuControl", "on_pause_disabled")
	
	_level_loader_thread = preload("res://scripts/level_loader.gd").new()
	_level_loader_thread.start()
	
	_set_spawn_locations()
	
	var _controllers = Input.get_connected_joypads()
	for controller in _controllers:
		_add_new_player(controller)
	
	yield(ScreenTransition.fade_in(), "completed")


func _process(_delta : float) -> void:
	if not _unhandled_joystick_connections.empty() and _can_handle_joystick_connections:
		# Handles all unhandled joystick connection events and clears dictionary
		for key in _unhandled_joystick_connections.keys():
			on_controller_connection_changed(key, _unhandled_joystick_connections[key])
		_unhandled_joystick_connections.clear()


func _exit_tree() -> void:
	_level_loader_thread.stop_thread()


func on_controller_connection_changed(device : int, connected : bool) -> void:
	if not _can_handle_joystick_connections:
		_unhandled_joystick_connections[device] = connected
		return
	
	if connected:
		_add_new_player(device)
	else:
		_remove_player(device)


func on_start_loading_next_level() -> void:
	if LEVELS_STACK.size() > 1:
		_level_loader_thread.queue_level(LEVELS_STACK[1])


func on_cancel_loading_next_level() -> void:
	_level_loader_thread.cancel_loading_level()


func on_go_to_next_level() -> void:
	if LEVELS_STACK.size() == 1:
		_finish_game()
		return
	
	print("Going to level " + LEVELS_STACK[1])
	
	yield(_swap_scenes(LEVELS_STACK[1]), "completed")
	LEVELS_STACK.remove(0)
	_level_loaded()


func on_player_busted(caught_players : Array) -> void:
	for player_node in caught_players:
		for controller_num in _controller_player_dict.keys():
			if player_node == _controller_player_dict[controller_num]:
				_vibrate_controller(controller_num, 0.5)
	
	emit_signal("can_pause_disabled")
	emit_signal("game_over")
	
	on_restart_level()


func on_restart_level() -> void:
	yield(_swap_scenes(LEVELS_STACK[0]), "completed")
	_level_loaded()


func on_go_to_main_menu() -> void:
	yield(ScreenTransition.fade_out(), "completed")
	
	var main_menu : Control = _level_loader_thread.get_level(MAIN_MENU_PATH).instance() as Control
	$"/root".add_child(main_menu)
	
	var old_scene : Node = $"/root/Main" as Node
	$"/root".remove_child(old_scene)
	old_scene.call_deferred("free")


# Each controller corresponds to an integer id, this function returns an array of them.
func get_controller_indices() -> Array:
	return _controller_player_dict.keys()


func _set_spawn_locations() -> void:
	var root_3d : Spatial = $"/root/Main/Root3D"
	
	_new_player_spawn_locations = [
		(root_3d.get_node("PlayerSpawnLocations/Spawn1") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn2") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn3") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn4") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn5") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn6") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn7") as Spatial).translation,
		(root_3d.get_node("PlayerSpawnLocations/Spawn8") as Spatial).translation
	]


func _swap_scenes(level_path : String) -> void:
	_can_handle_joystick_connections = false
	
	yield(ScreenTransition.fade_out(), "completed")
	
	# Remove old Root3D node
	var old_scene : Spatial = $"/root/Main/Root3D" as Spatial
	$"/root/Main".remove_child(old_scene)
	old_scene.call_deferred("free")
	
	# Add newly loaded Root3D node
	var next_scene : Spatial = _level_loader_thread.get_level(level_path).instance()
	$"/root/Main".add_child(next_scene)


func _level_loaded() -> void:
	_can_handle_joystick_connections = true
	
	_set_spawn_locations()
	
	# Move all players into their initial positions in the newly loaded level
	var index : int
	for player in _controller_player_dict.values():
		index = player.name[6].to_int()
		player.translation = _new_player_spawn_locations[index - 1]
	
	yield(ScreenTransition.fade_in(), "completed")
	
	emit_signal("can_pause_enabled")
	emit_signal("enable_player_input")


func _vibrate_controller(device : int, duration : float) -> void:
	Input.start_joy_vibration(device, 0, 1, duration)


func _add_new_player(device : int) -> void:
	# Instance new player
	var new_player : Spatial = preload("res://scenes/player/player.tscn").instance() as Spatial
	
	# Set new player properties
	new_player.name = "Player" + String(device + 1)
	new_player.translation = _new_player_spawn_locations[device]
	
	# Add new player to scene
	$"/root/Main/Players".add_child(new_player)
	
	_controller_player_dict[device] = new_player
	
	emit_signal("add_player", new_player)


func _remove_player(device : int) -> void:
	var player : Node = _controller_player_dict[device]
	
	emit_signal("remove_player", player)
	
	player.queue_free()
	
	if not _controller_player_dict.erase(device):
		printerr("Error removing " + player.name + " with joystick id " + String(device))


func _finish_game() -> void:
	_level_loader_thread.queue_level(MAIN_MENU_PATH)
	
	var elapsed_time : float = ($"/root/Main/ElapsedTimeTracker" as TimeTracker).get_elapsed_time_and_stop_tracking()
	var formatted_elapsed_time : String = _get_formatted_elapsed_time(elapsed_time)
	
	var time : Dictionary = OS.get_datetime()
	var finished_time : String = "%02d.%02d.%04d %02d:%02d" % [time.day, time.month, time.year, time.hour, time.minute]
	
	print("Game finished, showing team name screen")
	
	yield(ScreenTransition.fade_out(), "completed")
	
	var team_name_ui_node : Control = _show_team_name_screen()
	var team_name : String = yield(team_name_ui_node, "team_name_entered")
	
	LeaderboardManager.save_to_file(team_name, formatted_elapsed_time, finished_time)
	
	print("Saving info to leaderboard, going to main menu")
	
	on_go_to_main_menu()


func _get_formatted_elapsed_time(elapsed_time : float) -> String:
	if elapsed_time > 3600:
		return "59 min 59 sec"
	
	var seconds : float = fmod(elapsed_time, 60)
	var minutes : float = fmod(elapsed_time, 3600) / 60
	return "%02d min %02d sec" % [minutes, seconds]


func _show_team_name_screen() -> Control:
	_remove_level_gameplay_nodes()
	
	# Load team name UI
	var team_name_ui_node : Control = preload("res://scenes/menus/team_name_input.tscn").instance()
	$"/root/Main".add_child(team_name_ui_node)
	
	return team_name_ui_node


func _remove_level_gameplay_nodes() -> void:
	var main : Node = $"/root/Main"
	main.get_node("ElapsedTimeTracker").queue_free()
	main.get_node("Camera").queue_free()
	main.get_node("Players").queue_free()
	main.get_node("PauseMenuControl").queue_free()
	main.get_node("Root3D").queue_free()
