class_name PlayerMovement
extends CharacterBody2D

#Movement Variables and Constants
var Spd = 100
const ACCEL = 10

@onready var anims = $Anims

var vel:Vector2

func _physics_process(delta):
	vel.x =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#vel.y =  Input.get_action_strength("move_down") - Input.get_action_strength("move_p")
	vel = vel.normalized()
	
	if vel.x > 0:
		anims.play("Right")
	elif vel.x < 0:
		anims.play("Left")
	else:
		anims.play("Middle")
	velocity.x = lerp(velocity.x,vel.x * Spd,ACCEL*delta)
	#velocity.y = lerp(velocity.y,vel.y*Spd,ACCEL*delta)
	move_and_slide()
