class_name PlayerMovement
extends CharacterBody2D

#Movement Variables and Constants
var Spd = 100
const ACCEL = 10
var SHIELD_ENERGY:int = 100

@onready var anims = $AnimationsRoot/Anims
@onready var projectile_spawn = $Markers/Projectile_Spawn
@onready var particles = $Particles
@onready var smoke = $Particles/Smoke
@onready var shoot_cooldown = $Timers/Shoot_Cooldown
@onready var shield_energy_deplete = $Timers/Shield_Energy_Deplete
@onready var shield = $Markers/Shield
@onready var shield_anim = $AnimationsRoot/Shield
@onready var collision_shape_2d = $CollisionShape2D

@onready var impact_sound = $Sounds/ImpactSound
@onready var failed_shoot = $Sounds/FailedShoot
@onready var death = $Sounds/Death
@onready var shield_sound = $Sounds/Shield

var shield_depletion = false

var can_move:bool = true

#Projectiles
const PROJECTILE_BASIC = preload("res://Scenes/Props/Projectiles/projectile_basic.tscn")
const EXPLOSION = preload("res://Scenes/Props/Projectiles/explosion.tscn")
const SPACE_CRAFT_JUNK = preload("res://Scenes/Props/Projectiles/space_craft_junk.tscn")
var vel:Vector2

func _ready():
	GV.Player = self

func _physics_process(delta):
	if can_move:
		look_at(get_global_mouse_position())
		vel.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		vel.y =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		vel = vel.normalized()
	else:
		vel.x = 0
		vel.y = 0
	velocity.x = lerp(velocity.x,vel.x * Spd,ACCEL*delta)
	velocity.y = lerp(velocity.y,vel.y*Spd,ACCEL*delta)
	move_and_slide()
	
func _on_shield_energy_deplete_timeout():
	if SHIELD_ENERGY > 0:
		SHIELD_ENERGY -= 1
	else:
		shield_energy_deplete.stop()
		shield_anim.play_backwards("OpenShield")
		shield.get_node("CollisionShape2D").set_deferred("disabled",true)


func _input(event):
	if can_move:
		if event is InputEventMouseButton:
			if event.button_mask == MOUSE_BUTTON_RIGHT and event.is_pressed():
				if shield.get_node("CollisionShape2D").disabled == true:
					if shoot_cooldown.time_left == 0:
						shoot_cooldown.start()
						shoot(1)
		
		
		
		if Input.is_action_just_pressed("skill_shield"):
			if shield_energy_deplete.time_left == 0:
				shield_energy_deplete.start()
				shield.get_node("CollisionShape2D").set_deferred("disabled",false)
				shield_anim.play("OpenShield")
				
			else:
				shield_energy_deplete.stop()
				shield.get_node("CollisionShape2D").set_deferred("disabled",true)
				shield_anim.play_backwards("OpenShield")

func damage(amount):
	var Defeated_Amount = 0
	for i in GV.States:
		var e = randf_range(0.1,2)
		GV.States[i] -= amount*e
		GV.States[i] = snappedf(GV.States[i],1)
		GS.SHAKE_CAMERA.emit()
		if GV.States[i] <= 0:
			GV.States[i] = 0
			Defeated_Amount += 1
	if Defeated_Amount >= 2:
		dead()
	impact_sound.play()

func shoot(type):
	if type == 1:
		var e = PROJECTILE_BASIC.instantiate()
		GV.Projectile_Container.add_child(e)
		e.global_position = projectile_spawn.global_position
		e.rotation = rotation + PI/2
		e.dir = rotation + PI/2
		e.creator = self

func dead():
	velocity = Vector2.ZERO
	can_move = false
	collision_shape_2d.set_deferred("disabled",true)
	GS.SHAKE_CAMERA.emit()
	shake(30)
	GS.PLAYER_DEAD.emit()
	
	var boom = EXPLOSION.instantiate()
	GV.Projectile_Container.call_deferred("add_child",boom)
	boom.global_position = global_position
	boom.z_index = z_index + 1
	
	for i in range(3):
		var part = SPACE_CRAFT_JUNK.instantiate()
		part.get_node("anims").play("Player"+str(i+1))
		GV.Objects_Container.call_deferred("add_child",part)
		part.global_position = global_position + Vector2(randf_range(-5,5),randf_range(-5,5))
		part.apply_central_impulse(global_position - part.global_position)
	
	
	anims.hide()
	shield_anim.hide()
	
func shake(amount):
	for i in range(amount):
		anims.offset.x = randf_range(-0.5,0.5)
		anims.offset.y = randf_range(-0.5,0.5)
		await get_tree().create_timer(0.01).timeout
	anims.offset.x = 0
	anims.offset.y = 0
	return true


func restore_energy(amount:int = 25):
	if SHIELD_ENERGY < 100:
		SHIELD_ENERGY += amount
	else:
		SHIELD_ENERGY = 100
