extends Control

signal activate_enemy
signal disable_player_movement
signal disable_game_pause_functionality
signal go_to_main_menu

const _tutorial_win_texts : Array = [
	"""[center]Now you know how to complete levels! The total time it takes to complete all levels (except when the game is paused) is tracked and can be entered into the leaderboard at the end of the game.
	
	Press [img=32]res://ui/icons/a_button.png[/img] to continue.[/center]""",
	
	"""[center]The game is meant to be played with [color=#00ff00]2-4 players[/color], since you need to cooperate to get through levels. Players can join/leave the game at any time.
	
	Press [img=32]res://ui/icons/a_button.png[/img] to continue.[/center]""",
	
	"""[center]You have [color=#ff0000]60 seconds[/color] to complete each level (does not apply to the tutorial). You can keep track of this by looking at the sun's direction and color. If you take longer than 60 seconds to complete a level, that level will be restarted.
	
	Press [img=32]res://ui/icons/a_button.png[/img] to continue.[/center]""",
	
	"""[center]Have [color=#ff0000]f[/color][color=#00ff00]u[/color][color=#0000ff]n[/color]!
	
	Press [img=32]res://ui/icons/a_button.png[/img] to return to the main menu.[/center]"""
]

var _player_interacted_with_computer : bool = false
var _player_interacted_got_caught : bool = false
var _player_can_advance_win_area_text : bool = false

onready var _tutorial_content : RichTextLabel = $Panel/TutorialContent as RichTextLabel


func _ready() -> void:
	self.connect("disable_game_pause_functionality", $"../PauseMenuControl", "on_pause_disabled")
	self.connect("go_to_main_menu", $"../GameManager", "on_go_to_main_menu")


func on_player_interacted_with_computer() -> void:
	if _player_interacted_with_computer:
		return
	
	_player_interacted_with_computer = true
	
	_tutorial_content.bbcode_text = """[center] The door opened, move into the marked area.
	
	But watch out! Those guards are looking for you.
	
	Stay out of their vision cones. You can hide behind walls and other objects in the room.[/center]"""
	
	emit_signal("activate_enemy")


func on_player_got_caught() -> void:
	if _player_interacted_got_caught:
		return
	
	_player_interacted_got_caught = true
	
	_tutorial_content.bbcode_text = """[center]Oh no! You got caught!
	
	Luckily nothing happened since this is a tutorial, but in an actual level you would be forced to restart.
	
	Keep moving to the goal area.[/center]"""


func on_first_player_entered_win_area() -> void:
	_tutorial_content.bbcode_text = """[center]Great! Once everyone gets into the area, you can progress to the next level.[/center]"""


func on_all_players_entered_win_area() -> void:
	_tutorial_content.bbcode_text = """[center]Now you need to stay in the goal area until the bar fills up. After that the level is completed.[/center]"""


func on_tutorial_end() -> void:
	_tutorial_content.bbcode_text = _tutorial_win_texts[0]
	_player_can_advance_win_area_text = true
	
	emit_signal("disable_player_movement")
	emit_signal("disable_game_pause_functionality")


func on_trigger_next_win_area_text() -> void:
	if _tutorial_win_texts.size() > 1:
		_tutorial_win_texts.remove(0)
		_tutorial_content.bbcode_text = _tutorial_win_texts[0]
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		
		print("Tutorial ended, going to main menu")
		
		emit_signal("go_to_main_menu")


func _input(event : InputEvent) -> void:
	if not _player_can_advance_win_area_text:
		return
	
	if event.is_action_pressed("ui_accept"):
		on_trigger_next_win_area_text()
