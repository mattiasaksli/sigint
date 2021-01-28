extends Spatial

var SPEED : float = 200
var RADIUS : float = 0.75
var direction : Vector3

func init(dir : Vector2):
	direction = Vector3(dir.x, dir.y, 0).normalized()

func _ready():
	pass

func _process(delta):
	translation += direction * SPEED * delta
