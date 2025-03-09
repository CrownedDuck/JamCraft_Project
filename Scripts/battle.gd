extends Node2D
@onready var bg = $BG

@onready var projectile_container = $Projectile_Container
@onready var enemy_spawns = $Enemy_Spawns
@onready var enemies = $Enemies


var SCR_SPD:float = 1.0
var OFFSET:float

signal CONTINUE

func _ready():
	GV.Projectile_Container = projectile_container
	GV.MAP_CENTER = enemy_spawns.get_node("CENTER_TARGET").global_position
	SPAWN_LEVEL()

func _process(delta):
	OFFSET += SCR_SPD*delta
	bg.material.set_shader_parameter("Time",OFFSET)

func SPAWN_LEVEL():
	var e = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER)+".tres")
	if e:
		var dialogue = e.Dialogue_Played_at_Start
		if dialogue != null:
			GV.Player.can_move = false
			DialogueManager.show_dialogue_balloon(dialogue,'start')
			await CONTINUE
			GV.Player.can_move = true
		for i in e.Enemies:
			var o = i.instantiate()
			enemies.add_child(o)
			if e.Name != "Safe Zone":
				o.global_position = enemy_spawns.get_node("S"+str(randi_range(1,3))).global_position
			else:
					o.global_position = enemy_spawns.get_node("S"+str(1)).global_position
			await get_tree().create_timer(e.Enemy_Spawn_Dif).timeout

func NEXT_LEVEL():
	GS.NEXT_LEVEL.emit()
	GV.LEVEL_NUMBER += 1
	SPAWN_LEVEL()


func _on_enemies_child_order_changed():
	if enemies.get_child_count() == 0:
		NEXT_LEVEL()
