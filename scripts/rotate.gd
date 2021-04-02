extends Spatial

export var angle_radians : float = 0.75


func _process(delta : float) -> void:
	self.rotate_y(angle_radians * delta)
