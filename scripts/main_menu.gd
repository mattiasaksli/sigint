extends Control

const level1 : String = "res://scenes/levels/level1.tscn"
const tutorial : String = "res://scenes/levels/tutorial.tscn"


func _ready() -> void:
	($Panel/VBoxContainer/NewGameBtn as Control).grab_focus()


func on_new_game_started() -> void:
	var level1_scene : Node = (ResourceLoader.load(level1) as PackedScene).instance()
	$"/root".add_child(level1_scene)
	self.queue_free()


func on_tutorial_started() -> void:
	var tutorial_scene : Node = (ResourceLoader.load(tutorial) as PackedScene).instance()
	$"/root".add_child(tutorial_scene)
	self.queue_free()


func on_leaderboard_opened() -> void:
	print("leaderboard")


func on_options_opened() -> void:
	print("options")


func on_quit_game() -> void:
	get_tree().quit()
