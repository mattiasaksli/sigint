class_name PauseMenu

extends Control

signal restart_level
signal go_to_main_menu

var _is_game_paused : bool = false
var _can_pause_game : bool = true


func _ready() -> void:
	var game_manager : GameManager = $"/root/Main/GameManager" as GameManager
	self.connect("restart_level", game_manager, "on_restart_level")
	self.connect("go_to_main_menu", game_manager, "on_go_to_main_menu")


func _input(event : InputEvent) -> void:
	if not _can_pause_game:
		return
	
	if event.is_action_pressed("ui_pause"):
		_is_game_paused = !_is_game_paused
		
		if _is_game_paused:
			pause_game()
		else:
			resume_game()
	elif _is_game_paused and event.is_action_pressed("ui_cancel"):
		resume_game()


func pause_game() -> void:
	get_tree().paused = true
	self.show()
	($TransparentBGPanel/OpaquePanelContainer/MarginContainer/VSplitContainer/ButtonsVBox/ResumeBtn as Control).grab_focus()


func resume_game() -> void:
	get_tree().paused = false
	self.hide()


func restart_level_pressed() -> void:
	emit_signal("restart_level")
	_is_game_paused = false
	resume_game()


func main_menu_pressed() -> void:
	emit_signal("go_to_main_menu")
	_is_game_paused = false
	resume_game()


func on_pause_disabled() -> void:
	_can_pause_game = false


func on_pause_enabled() -> void:
	_can_pause_game = true
