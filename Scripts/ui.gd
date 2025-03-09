extends CanvasLayer
@onready var level = $Panels/Level


func _ready():
	GS.ENABLE_UI.connect(ENABLE_UI)
	GS.NEXT_LEVEL.connect(change_level_text)
	GS.END.connect(end)
	GS.PLAYER_DEAD.connect(close)
	if GV.LEVEL_NUMBER != 0:
		ENABLE_UI()

func change_level_text():
	var lvl = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER)+".tres")
	if lvl:
		level.text = lvl.Name
	else:
		print("LVL non existant")

func close():
	$AnimationPlayer.play("Disable")
	#GAMEOVER
	$Panels/STATE.text = "GAME OVER"

func end():
	$AnimationPlayer.play("Disable")
	#GAMEOVER
	$Panels/STATE.text = "THE END\n (or is it?)"

func ENABLE_UI():
	$AnimationPlayer.play("Start")
