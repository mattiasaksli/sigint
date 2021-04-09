extends PauseMenu

func restart_level_pressed() -> void:
	# TODO: change to screen transition
	yield(get_tree().create_timer(1.0), "timeout")
	
	_is_game_paused = false
	resume_game()
	
	get_tree().current_scene = $"/root/Main"
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
