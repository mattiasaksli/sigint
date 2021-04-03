extends Sprite3D


func _ready() -> void:
	texture = ($Viewport as Viewport).get_texture()
