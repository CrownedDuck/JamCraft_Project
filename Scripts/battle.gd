extends Node2D
@onready var bg = $BG

@onready var projectile_container = $Projectile_Container

var SCR_SPD:float = 1.0
var OFFSET:float

func _ready():
	GV.Projectile_Container = projectile_container

func _process(delta):
	OFFSET += SCR_SPD*delta
	bg.material.set_shader_parameter("Time",OFFSET)
