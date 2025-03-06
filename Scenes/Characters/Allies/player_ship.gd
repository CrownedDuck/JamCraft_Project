class_name PlayerMovement
extends CharacterBody2D

#Movement Variables and Constants
var Spd = 100
const ACCEL = 10

@onready var anims = $Anims
@onready var projectile_spawn = $Projectile_Spawn
@onready var impact_sound = $Sounds/ImpactSound
@onready var particles = $Particles
@onready var smoke = $Particles/Smoke

#Projectiles
const PROJECTILE_BASIC = preload("res://Scenes/Props/Projectiles/projectile_basic.tscn")

var vel:Vector2

func _physics_process(delta):
	look_at(get_global_mouse_position())
	vel.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	vel.y =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	vel = vel.normalized()
	
	velocity.x = lerp(velocity.x,vel.x * Spd,ACCEL*delta)
	velocity.y = lerp(velocity.y,vel.y*Spd,ACCEL*delta)
	move_and_slide()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT and event.is_pressed():
			if !GV.OVERHEATED:
				var e = PROJECTILE_BASIC.instantiate()
				GV.Projectile_Container.add_child(e)
				e.global_position = projectile_spawn.global_position
				e.Spawn_Pos = global_position
				e.Spawn_Rot = rotation + PI/2
				e.dir = rotation + PI/2
				if GV.OVERHEAT_AMOUNT >= 100:
					GV.OVERHEATED = true
					GS.OVERHEATED.emit()
					smoke.emitting = true
				else:
					for i in range(10):
						GV.OVERHEAT_AMOUNT += 1
						await get_tree().create_timer(0.05).timeout
					smoke.emitting = false

func damage(amount):
	for i in GV.States:
		var e = randf_range(1,2)
		GV.States[i] -= amount*e
		GV.States[i] = snappedf(GV.States[i],1)
		GS.SHAKE_CAMERA.emit()
	impact_sound.play()
