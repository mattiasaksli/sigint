class_name WinArea

extends Area

signal go_to_next_level

var _players_in_win_area : Dictionary
var _game_manager : GameManager
var _is_tween_paused : bool = false

onready var _timer : Timer = $Timer as Timer
onready var _tween : Tween = $Tween as Tween
onready var _goal_progress_bar : TextureProgress = $GoalBar/Viewport/GoalProgressBar as TextureProgress


func _enter_tree():
	# Set up signals for the current level
	_game_manager = $"/root/Main/GameManager" as GameManager
	
	_game_manager.connect("add_player", self, "new_player_spawned")
	_game_manager.connect("remove_player", self, "player_despawned")
	self.connect("go_to_next_level", _game_manager, "on_go_to_next_level")


func _ready() -> void:
	# HACK: to make sure that on_player_entered is not called from the new win area when the level changes
	yield(get_tree().create_timer(0.1), "timeout")


func on_player_entered(body: Node) -> void:
	_players_in_win_area[body] = true
	
	for player in get_tree().get_nodes_in_group("players"):
		if not _players_in_win_area.has(player):
			_players_in_win_area[player] = false
	
	if _are_all_players_in_win_area():
		_start_loading_next_level()


func on_player_exited(body: Node) -> void:
	if body in _players_in_win_area:
		# Happens if the player is not despawned
		_players_in_win_area[body] = false
	
	# Not all players are in the win area, resets the timer and level loading
	if not _timer.is_stopped():
		_cancel_loading_next_level()
	
	# This passes if all of the remaining players are already in the win area
	if _are_all_players_in_win_area():
		_start_loading_next_level()


func on_progress_bar_full():
	emit_signal("go_to_next_level")


func new_player_spawned(new_player : Node):
	# New player spawned at spawn location
	_players_in_win_area[new_player] = false
	
	if _tween and _tween.is_active():
		_cancel_loading_next_level()


func player_despawned(old_player : Node):
	# Player despawned, on_player_exited() will handle stopping the timer
	
	if old_player in _players_in_win_area:
		# Deletes the player from list, if the node has not been deleted yet
		_players_in_win_area.erase(old_player)
	else:
		# The node has already been removed from the scene, deletes the null ref player from the dictionary
		for player in _players_in_win_area:
			if player == null:
				_players_in_win_area.erase(player)


func _are_all_players_in_win_area() -> bool:
	for is_present in _players_in_win_area.values():
		if not is_present:
			return false
	
	return true


func _start_loading_next_level() -> void:
	_timer.start()
	
	if _is_tween_paused:
		# Resumes interpolating the progress bar
		
		_tween.resume(_goal_progress_bar, "value")
	else:
		# Starts interpolating the progress bar
		
		_tween.interpolate_property(_goal_progress_bar, "value", 0, 100, _timer.wait_time)
		_tween.start()


func _cancel_loading_next_level() -> void:
	_timer.stop()
	
	# Stop interpolating the progress bar
	_tween.stop(_goal_progress_bar, "value")
	_tween.reset(_goal_progress_bar, "value")
