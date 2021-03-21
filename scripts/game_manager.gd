extends Node

signal game_over

var _new_player_spawn_locations : Array
var _controller_player_dict : Dictionary
var _can_handle_joystick_connections : bool = true
var _unhandled_joystick_connections : Dictionary


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Input.connect("joy_connection_changed", self, "on_controller_connection_changed")
	
	initialize_variables()
	
	var _controllers = Input.get_connected_joypads()
	for controller in _controllers:
		_add_new_player(controller)


func _process(_delta : float) -> void:
	if not _unhandled_joystick_connections.empty() and _can_handle_joystick_connections:
		# Handles all unhandled joystick connection events and clears dictionary
		for key in _unhandled_joystick_connections.keys():
			on_controller_connection_changed(key, _unhandled_joystick_connections[key])
		_unhandled_joystick_connections.clear()


func initialize_variables() -> void:
	_new_player_spawn_locations = [
		($"/root/Root3D/PlayerSpawnLocations/Spawn1" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn2" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn3" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn4" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn5" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn6" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn7" as Spatial).translation,
		($"/root/Root3D/PlayerSpawnLocations/Spawn8" as Spatial).translation,
	]


func on_controller_connection_changed(device : int, connected : bool) -> void:
	if not _can_handle_joystick_connections:
		_unhandled_joystick_connections[device] = connected
		return
	
	if connected:
		_add_new_player(device)
	else:
		_remove_player(device)


func on_new_level_loaded() -> void:
	_can_handle_joystick_connections = true
	
	initialize_variables()
	
	# Move all players into their initial positions in the newly loaded level
	var index : int
	for player in _controller_player_dict.values():
		index = player.name[6].to_int()
		player.translation = _new_player_spawn_locations[index - 1]


func on_player_busted() -> void:
	emit_signal("game_over")


func _add_new_player(device : int) -> void:
	# Instance new player
	var new_player : Spatial = preload("res://scenes/player/player.tscn").instance() as Spatial
	
	# Set new player properties
	new_player.name = "Player" + String(device + 1)
	new_player.translation = _new_player_spawn_locations[device]
	
	# Add new player to scene
	$"/root/Players".add_child(new_player)
	
	_controller_player_dict[device] = new_player
	
	print("Added " + new_player.name + " with joystick id " + String(device) + " at position " + String(_new_player_spawn_locations[device]))


func _remove_player(device : int) -> void:
	print("Removed " + _controller_player_dict[device].name + " with joystick id " + String(device))
	
	_controller_player_dict[device].queue_free()
	
	if not _controller_player_dict.erase(device):
		printerr("Error removing " + _controller_player_dict[device].name + " with joystick id " + String(device))
