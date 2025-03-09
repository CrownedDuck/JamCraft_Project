extends RigidBody2D
@onready var anims = $Anims

func _ready():
	anims.rotation = randf_range(-1,1)
	apply_central_impulse(Vector2(0,100))
