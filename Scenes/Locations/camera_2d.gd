extends Camera2D

func _ready():
	GS.SHAKE_CAMERA.connect(shake)
	GS.END.connect(on_END)

func shake():
	for i in range(10):
		offset.x = randf_range(-1,1)
		offset.y = randf_range(-1,1)
		await get_tree().create_timer(0.01).timeout
	offset.x = 0
	offset.y = 0

func on_END():
	$AnimationPlayer.play("END")
