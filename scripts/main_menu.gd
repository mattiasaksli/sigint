extends Control

const LEVEL_GLOBALS_AND_LEVEL1_PATH : String = "res://scenes/levels/level_globals_and_level1.tscn"
const TUTORIAL_PATH : String = "res://scenes/levels/tutorial.tscn"


func _ready() -> void:
	($Panel/VBoxContainer/NewGameBtn as Control).grab_focus()
	
	# TODO: disable input for a bit to stop immediate nwe game start


func on_new_game_started() -> void:
	var level_globals_and_level1_scene : Node = (ResourceLoader.load(LEVEL_GLOBALS_AND_LEVEL1_PATH) as PackedScene).instance()
	$"/root".add_child(level_globals_and_level1_scene)
	self.queue_free()


func on_tutorial_started() -> void:
	var tutorial_scene : Node = (ResourceLoader.load(TUTORIAL_PATH) as PackedScene).instance()
	$"/root".add_child(tutorial_scene)
	self.queue_free()


func on_leaderboard_opened() -> void:
	print("leaderboard")


func on_options_opened() -> void:
	print("options")


func on_quit_game() -> void:
	get_tree().quit()
