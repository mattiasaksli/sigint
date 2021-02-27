extends Node

signal game_over


func on_player_busted() -> void:
	emit_signal("game_over")
