extends Node2D
@onready var bg = $BG

@onready var projectile_container = $Projectile_Container
@onready var enemy_spawns = $Enemy_Spawns
@onready var enemies = $Enemies
@onready var space_objects = $Space_Objects
@onready var item_spawn = $ItemSpawn

@onready var asteroid_pos = $Enemy_Spawns/Asteroid_Spawn/Asteroid_Pos

const METEORITE = preload("res://Scenes/Props/Projectiles/meteorite.tscn")

var SCR_SPD:float = 1.0
var OFFSET:float
signal CONTINUE

func _ready():
	MM.change_music("Start")
	GV.FightScene = self
	GV.Objects_Container = space_objects
	GV.Projectile_Container = projectile_container
	GS.PLAYER_DEAD.connect(_player_dead)
	GV.MAP_CENTER = enemy_spawns.get_node("CENTER_TARGET").global_position
	SPAWN_LEVEL()


func _process(delta):
	OFFSET += SCR_SPD*delta
	bg.material.set_shader_parameter("Time",OFFSET)

func SPAWN_LEVEL():
	var e = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER)+".tres")
	if e:
		if e.Name == "Safe Zone":
			MM.change_music("Start")
		elif e.Name == "Open Space":
			MM.change_music("Fight1")
		elif e.Name == "Pirate Territory":
			MM.change_music("Fight2")
		
		GS.NEXT_LEVEL.emit()
		var dialogue = e.Dialogue_Played_at_Start
		if dialogue != null:
			if is_instance_valid(GV.Player):
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
			if get_tree():
				await get_tree().create_timer(e.Enemy_Spawn_Dif).timeout
		
		if e.Field_Effect == "METEORITES":
			#if is_instance_valid(item_spawn):
			if item_spawn.time_left == 0:
				item_spawn.start()
		else:
			#if is_instance_valid(item_spawn):
			if item_spawn.time_left == 0:
				item_spawn.stop()

func NEXT_LEVEL():
	GV.LEVEL_NUMBER += 1
	SPAWN_LEVEL()

func _player_dead():
	await get_tree().create_timer(2).timeout
	DialogueManager.show_dialogue_balloon(load("res://Resources/Dialogues/PlayAgain.dialogue"),'start')


func _on_enemies_child_order_changed():
	if enemies.get_child_count() == 0:
		NEXT_LEVEL()

func _restart_level():
	var o = load("res://Resources/Levels/"+"LVL_"+str(GV.LEVEL_NUMBER+1)+".tres")
	if is_instance_valid(o):
		GV.LEVEL_NUMBER -= 1
	else:
		GV.LEVEL_NUMBER -= 2
	for i in GV.States:
		GV.States[i] = 100
	get_tree().reload_current_scene()


func _restart_game():
	GV.LEVEL_NUMBER = -1
	for i in GV.States:
		GV.States[i] = 100
	get_tree().reload_current_scene()


func _on_item_spawn_timeout():
	if is_inside_tree():
		asteroid_pos.progress_ratio = randf_range(0,1)
		var meteorite = METEORITE.instantiate()
		space_objects.call_deferred("add_child",meteorite)
		meteorite.global_position = asteroid_pos.global_position
