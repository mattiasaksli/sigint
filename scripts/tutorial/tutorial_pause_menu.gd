extends PauseMenu

func restart_level_pressed() -> void:
	yield(ScreenTransition.fade_out(), "completed")
	
	_is_game_paused = false
	resume_game()
	
	get_tree().current_scene = $"/root/Main"
	get_tree().reload_current_scene()
