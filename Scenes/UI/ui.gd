extends CanvasLayer
@onready var level = $Panels/Level

func _ready():
	GS.NEXT_LEVEL.connect(change_level_text)

func change_level_text():
	var lvl = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER)+".tres")
	if lvl:
		level.text = lvl.Name
	else:
		print("LVL non existant")
