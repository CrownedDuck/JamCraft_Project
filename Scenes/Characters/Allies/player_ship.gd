class_name PlayerMovement
extends CharacterBody2D

#Movement Variables and Constants
var Spd = 100
const ACCEL = 10
var SHIELD_ENERGY:int = 100

@onready var anims = $AnimationsRoot/Anims
@onready var projectile_spawn = $Markers/Projectile_Spawn
@onready var impact_sound = $Sounds/ImpactSound
@onready var particles = $Particles
@onready var smoke = $Particles/Smoke
@onready var shoot_cooldown = $Timers/Shoot_Cooldown
@onready var shield_energy_manage = $Timers/Shield_Energy_manage

@onready var shield = $Markers/Shield

var shield_depletion = false

var can_move:bool = true

#Projectiles
const PROJECTILE_BASIC = preload("res://Scenes/Props/Projectiles/projectile_basic.tscn")

var vel:Vector2

func _ready():
	GV.Player = self

func _physics_process(delta):
	print(SHIELD_ENERGY)
	if can_move:
		look_at(get_global_mouse_position())
		vel.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		vel.y =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		vel = vel.normalized()
	
	velocity.x = lerp(velocity.x,vel.x * Spd,ACCEL*delta)
	velocity.y = lerp(velocity.y,vel.y*Spd,ACCEL*delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("skill_shield"):
		shield_energy_manage.start()
	
	
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if shoot_cooldown.time_left == 0:
				shoot_cooldown.start()
				shoot(1)

func damage(amount):
	for i in GV.States:
		var e = randf_range(0.1,2)
		GV.States[i] -= amount*e
		GV.States[i] = snappedf(GV.States[i],1)
		GS.SHAKE_CAMERA.emit()
	impact_sound.play()

func shoot(type):
	if type == 1:
		var e = PROJECTILE_BASIC.instantiate()
		GV.Projectile_Container.add_child(e)
		e.global_position = projectile_spawn.global_position
		e.rotation = rotation + PI/2
		e.dir = rotation + PI/2
		e.creator = self


func _on_shield_energy_recharge_timeout():
	if SHIELD_ENERGY < 100:
		SHIELD_ENERGY += 1
	else:
		shield_energy_manage.stop()
