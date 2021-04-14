extends DirectionalLight

signal game_over

onready var _animator : AnimationPlayer = $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	self.connect("game_over", $"/root/Main/GameManager", "on_player_busted")
	
	_animator.play("pass_time")


func on_sun_finished_rotating(_anim_name : String) -> void:
	# Check if this is the tutorial
	if get_node_or_null("/root/Main/TutorialControl"):
		return
	
	emit_signal("game_over", $"/root/Main/Players".get_children())
