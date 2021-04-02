extends Node

signal level_loaded


func _ready():
	var game_manager = $"/root/Main/GameManager"
	# warning-ignore:return_value_discarded
	self.connect("level_loaded", game_manager, "on_new_level_loaded")

# When the new Root3D node enters the scene tree,
# it is assigned a different name because the old Root3D has not yet left the scene tree.
# Process assigns the original name to the new Root3D node.
func _process(_delta : float) -> void:
	if get_node_or_null("/root/Main/Root3D") == null:
		self.name = "Root3D"
		
		emit_signal("level_loaded")
		
		set_script(null)
