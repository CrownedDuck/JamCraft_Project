extends Node2D
@onready var bg = $BG

@onready var projectile_container = $Projectile_Container
@onready var enemy_spawns = $Enemy_Spawns
@onready var enemies = $Enemies


var SCR_SPD:float = 1.0
var OFFSET:float

func _ready():
	GV.Projectile_Container = projectile_container
	GV.MAP_CENTER = enemy_spawns.get_node("CENTER_TARGET").global_position
	SPAWN_LEVEL()

func _process(delta):
	OFFSET += SCR_SPD*delta
	bg.material.set_shader_parameter("Time",OFFSET)

func SPAWN_LEVEL():
	GS.NEXT_LEVEL.emit()
	var e = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER)+".tres")
	if e:
		for i in e.Enemies:
			var o = e.Enemies[i][0].instantiate()
			enemies.add_child(o)
			o.global_position = enemy_spawns.get_node(e.Enemies[i][1]).global_position
func NEXT_LEVEL():
	GV.LEVEL_NUMBER += 1
	SPAWN_LEVEL()


func _on_enemies_child_order_changed():
	if enemies.get_child_count() == 0:
		NEXT_LEVEL()
