extends ProgressBar
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	value = GV.OVERHEAT_AMOUNT

func _ready():
	GS.OVERHEATED.connect(OVERHEAT)

func _on_timer_timeout():
	if GV.OVERHEATED:
		if GV.OVERHEAT_AMOUNT > 0:
			GV.OVERHEAT_AMOUNT -= 1
			timer.start()
		else:
			GV.OVERHEATED = false

func OVERHEAT():
	timer.start()
