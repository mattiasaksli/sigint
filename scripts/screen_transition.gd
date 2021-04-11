extends Node

onready var _screen_transition_animator : AnimationPlayer = $ScreenTransition/AnimationPlayer as AnimationPlayer


func fade_in() -> void:
	_screen_transition_animator.play("transition_in")
	yield(_screen_transition_animator, "animation_finished")


func fade_out() -> void:
	_screen_transition_animator.play("transition_out")
	yield(_screen_transition_animator, "animation_finished")
