extends Node

signal game_over

func on_player_busted():
	emit_signal("game_over")
	print_debug(self.name + " sent out the game over signal")
