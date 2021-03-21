extends Area

export var next_level_path : String

var _players_in_win_area : Dictionary
var _level_loader_thread : LevelLoader

onready var _timer : Timer = $Timer


func _ready() -> void:
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		_players_in_win_area[player] = false
	
	_level_loader_thread = preload("res://scripts/level_loader.gd").new()
	_level_loader_thread.start()


func on_player_entered(body: Node) -> void:
	_players_in_win_area[body] = true
	
	if _are_all_players_in_win_area():
		_win()


func on_player_exited(body: Node) -> void:
	_players_in_win_area[body] = false
	
	# Not all players are in the win area, stopping timer and level loading
	if not _timer.is_stopped():
		_timer.stop()
		_level_loader_thread.cancel_loading_level()


func _on_Timer_timeout():
	var next_scene : PackedScene = _level_loader_thread.get_level(next_level_path)
	#$"/root/Main".queue_free()
	if get_tree().change_scene_to(next_scene) == ERR_CANT_CREATE:
		printerr("Error changing scene to " + next_level_path)


func _are_all_players_in_win_area() -> bool:
	for is_present in _players_in_win_area.values():
		if not is_present:
			return false
	
	return true


func _win() -> void:
	_level_loader_thread.queue_level(next_level_path)
	_timer.start()
