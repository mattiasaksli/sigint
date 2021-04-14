extends Control

const LEVEL_GLOBALS_AND_LEVEL1_PATH : String = "res://scenes/levels/level_globals_and_level1.tscn"
const TUTORIAL_PATH : String = "res://scenes/levels/tutorial_globals_and_level.tscn"
const LEADERBOARD_ELEMENT_PATH : String = "res://scenes/menus/leaderboard_element.tscn"

enum {
	MENU_OPEN,
	OPTIONS_OPEN,
	LEADERBOARD_OPEN
}

var _menu_state : int

onready var _menu : VBoxContainer = $Panel/MenuButtonsVBox as VBoxContainer
onready var _leaderboard : Control = $Panel/Leaderboard as Control
onready var _options : Control = $Panel/OptionsMenu as Control

onready var _fullscreen_toggle : CheckButton = $Panel/OptionsMenu/VBoxContainer/FullscreenCheckButton as CheckButton


func _ready() -> void:
	_menu_state = MENU_OPEN
	(_menu.get_node("NewGameBtn") as Control).grab_focus()
	
	_fullscreen_toggle.pressed = OS.window_fullscreen
	
	yield(ScreenTransition.fade_in(), "completed")


func _input(event : InputEvent) -> void:
	if _menu_state == LEADERBOARD_OPEN:
		if event.is_action_pressed("ui_cancel"):
			_leaderboard.hide()
			_menu.show()
			_menu_state = MENU_OPEN
			(_menu.get_node("NewGameBtn") as Control).grab_focus()
		elif event.is_action_pressed("ui_up"):
			(_leaderboard.get_node("ScrollContainer") as ScrollContainer).scroll_vertical -= 55
		elif event.is_action_pressed("ui_down"):
			(_leaderboard.get_node("ScrollContainer") as ScrollContainer).scroll_vertical += 55
	elif _menu_state == OPTIONS_OPEN:
		if event.is_action_pressed("ui_cancel"):
			_options.hide()
			_menu.show()
			_menu_state = MENU_OPEN
			(_menu.get_node("NewGameBtn") as Control).grab_focus()


func on_new_game_started() -> void:
	$Panel/MenuButtonsVBox/NewGameBtn.disconnect("pressed", self, "on_new_game_started")
	
	print("Starting new game")
	
	yield(ScreenTransition.fade_out(), "completed")
	
	# Add level 1 node
	var level_globals_and_level1_scene : Node = (preload(LEVEL_GLOBALS_AND_LEVEL1_PATH) as PackedScene).instance()
	$"/root".add_child(level_globals_and_level1_scene)
	
	# Remove main menu node
	$"/root".remove_child(self)
	self.call_deferred("free")


func on_tutorial_started() -> void:
	$Panel/MenuButtonsVBox/TutorialBtn.disconnect("pressed", self, "on_tutorial_started")
	
	print("Starting tutorial")
	
	yield(ScreenTransition.fade_out(), "completed")
	
	var tutorial_scene : Node = (load(TUTORIAL_PATH) as PackedScene).instance()
	$"/root".add_child(tutorial_scene)
	
	# Remove main menu node
	$"/root".remove_child(self)
	self.call_deferred("free")


func on_leaderboard_opened() -> void:
	_update_leaderboard_ui()
	
	_menu_state = LEADERBOARD_OPEN
	_menu.hide()
	_leaderboard.show()


func on_options_opened() -> void:
	_menu_state = OPTIONS_OPEN
	_menu.hide()
	_options.show()
	
	_fullscreen_toggle.grab_focus()


func on_quit_game() -> void:
	get_tree().quit()


func _on_fullscreen_toggled(is_fullscreen : bool) -> void:
	OS.window_fullscreen = is_fullscreen


func _update_leaderboard_ui() -> void:
	var leaderboard_state : Array = LeaderboardManager.get_leaderboard_state()
	
	if leaderboard_state.size() == 0:
		print("leaderboard_empty")
	
	var leaderboard_element_packed : PackedScene = preload(LEADERBOARD_ELEMENT_PATH)
	var leaderboard_element_node : Control
	
	# Clear previous elements
	for leaderboard_element in _leaderboard.get_node("ScrollContainer/VBoxContainer").get_children():
		leaderboard_element.queue_free()
	
	# Add new element for each leaderboard entry
	for leaderboard_entry in leaderboard_state:
		# Get data from leaderboard
		var team_name : String = leaderboard_entry["team_name"]
		var elapsed_time : String = leaderboard_entry["elapsed_time"]
		var finished_time : String = leaderboard_entry["finished_time"]
		
		leaderboard_element_node = leaderboard_element_packed.instance() as Control
		
		var hbox_node : HBoxContainer = leaderboard_element_node.get_node("Panel/CenterContainer/HBoxContainer") as HBoxContainer
		(hbox_node.get_node("TeamName") as Label).text = team_name
		(hbox_node.get_node("TimeElapsed") as Label).text = elapsed_time
		(hbox_node.get_node("Finished") as Label).text = finished_time
		
		_leaderboard.get_node("ScrollContainer/VBoxContainer").add_child(leaderboard_element_node)
