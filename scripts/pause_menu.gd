class_name PauseMenu

extends Control

signal restart_level

var _is_game_paused : bool = false
var _can_pause_game : bool = true


func _ready() -> void:
	var game_manager = $"/root/Main/GameManager"
	# warning-ignore:return_value_discarded
	self.connect("restart_level", game_manager, "on_restart_level")


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
	# TODO: change to screen transition
	yield(get_tree().create_timer(1.0), "timeout")
	
	emit_signal("restart_level")
	_is_game_paused = false
	resume_game()


func main_menu_pressed() -> void:
	var main_menu_scene : Control = (preload("res://scenes/menus/main_menu.tscn").instance() as Control)
	$"/root".add_child(main_menu_scene)
	
	_is_game_paused = false
	resume_game()
	
	$"/root/Main".queue_free()


func on_pause_disabled() -> void:
	_can_pause_game = false


func on_pause_enabled() -> void:
	_can_pause_game = true
