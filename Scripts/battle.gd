extends Node2D
@onready var bg = $BG

var SCR_SPD:float = 1.0
var OFFSET:float
func _process(delta):
	OFFSET += SCR_SPD*delta
	bg.material.set_shader_parameter("Time",OFFSET)
