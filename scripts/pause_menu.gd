extends Control

var paused : bool = false


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		paused = !paused
		
		if paused:
			pause_game()
		else:
			resume_game()
	elif paused and event.is_action_pressed("ui_cancel"):
		resume_game()


func pause_game() -> void:
	get_tree().paused = true
	self.show()
	($TransparentBGPanel/OpaquePanelContainer/MarginContainer/VSplitContainer/ButtonsVBox/ResumeBtn as Control).grab_focus()


func resume_game() -> void:
	get_tree().paused = false
	self.hide()


func restart_level() -> void:
	print("restarting")


func go_to_main_menu() -> void:
	var main_menu_scene : Control = (preload("res://scenes/menus/main_menu.tscn").instance() as Control)
	$"/root".add_child(main_menu_scene)
	$"/root/Main".queue_free()
