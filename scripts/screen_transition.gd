extends Node

export var normal_transition_color : Color = Color("#000000")
export var game_lost_transition_color : Color = Color("#4d0a0a")

onready var _screen_transition_animator : AnimationPlayer = $ScreenTransition/AnimationPlayer as AnimationPlayer
onready var _screen_transition_rect : ColorRect = $ScreenTransition as ColorRect


func fade_in(game_lost : bool = false) -> void:
	if game_lost:
		_screen_transition_rect.color = game_lost_transition_color
	else:
		_screen_transition_rect.color = normal_transition_color

	_screen_transition_animator.play("transition_in")
	yield(_screen_transition_animator, "animation_finished")


func fade_out(game_lost : bool = false) -> void:
	if game_lost:
		_screen_transition_rect.color = game_lost_transition_color
	else:
		_screen_transition_rect.color = normal_transition_color
	
	_screen_transition_animator.play("transition_out")
	yield(_screen_transition_animator, "animation_finished")
	yield(get_tree().create_timer(0.25), "timeout")
