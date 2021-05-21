extends WinArea

signal first_player_entered_win_area
signal all_players_entered_win_area
signal end_tutorial

const MAIN_MENU_PATH : String = "res://scenes/menus/main_menu.tscn"

var _first_player_entered_win_area : bool = false

onready var _tutorial_control : Control = $"/root/Main/TutorialControl" as Control


func _ready() -> void:
	self.connect("first_player_entered_win_area", _tutorial_control, "on_first_player_entered_win_area")
	self.connect("all_players_entered_win_area", _tutorial_control, "on_all_players_entered_win_area")
	self.connect("end_tutorial", _tutorial_control, "on_tutorial_end")


func on_player_entered(body: Node) -> void:
	if not _first_player_entered_win_area:
		_first_player_entered_win_area = true
		emit_signal("first_player_entered_win_area")
	
	.on_player_entered(body)


func on_progress_bar_full() -> void:
	_game_manager._is_switching_level = true
	
	emit_signal("end_tutorial")


func _start_loading_next_level() -> void:
	._start_loading_next_level()
	emit_signal("all_players_entered_win_area")
