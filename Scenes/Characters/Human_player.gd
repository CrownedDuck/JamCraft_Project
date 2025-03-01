extends CharacterBody2D

@onready var coyote_timer = $Timers/Coyote_Timer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var stun_recover_timer = $Timers/StunRecoverTimer

@onready var animation_player = $AnimationPlayer
@onready var anims = $Anims
@onready var particles = $Particles

@onready var picked_point = $Markers/Picked_point

const CHANGE_PARTICLE = preload("res://Scenes/Other/Particles/change_particle.tscn")

var coyote_time_activated:bool = false

var can_move = true

const jump_height:float = -330.0
const wall_ride: float = -110

var gravity:float = 12.0
const max_gravity:float = 14.5

const max_speed:float = 130
const acceleration:float = 8
const friction:float = 10

func _physics_process(delta):
	if can_move:
		var x_input:float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		var velocity_weight: float = delta * (acceleration if x_input else friction)
		velocity.x = lerp(velocity.x, x_input * max_speed, velocity_weight)
	
	
	#Calculate Gravity and Coyote time
	if is_on_floor():
		coyote_time_activated = false
		gravity = lerp(gravity, 12.0, 12.0 * delta)
	else:
		if coyote_timer.is_stopped() and !coyote_time_activated:
			coyote_timer.start()
			coyote_time_activated = true
		if Input.is_action_just_released("move_jump") or is_on_ceiling():
			velocity.y *= 0.5
		
		gravity = lerp(gravity, max_gravity, 12.0 * delta)
	
	#Detect Jump Inout
	if Input.is_action_just_pressed("move_jump") and can_move:
		if jump_buffer_timer.is_stopped():
			jump_buffer_timer.start()
	
	
	
	#Reset to Normal
	if !jump_buffer_timer.is_stopped() and (!coyote_timer.is_stopped() or is_on_floor()):
		velocity.y = jump_height
		jump_buffer_timer.stop()
		coyote_timer.stop()
		coyote_time_activated = true
	
	
	#Ledge Detector
	if velocity.y > -30 and velocity.y < -5 and abs(velocity.x) > 3:
		if $Rays/Left_Ledge_Hopper.is_colliding() and !$Rays/Left_Ledge_Hopper2.is_colliding() and velocity.x < 0:
			velocity.y += jump_height/3.25
		if $Rays/Right_Ledge_Hopper.is_colliding() and !$Rays/Right_Ledge_Hopper2.is_colliding() and velocity.x > 0:
			velocity.y += jump_height/3.25
		
	if ($Rays/Left_Ledge_Hopper.is_colliding() and $Rays/Left_Ledge_Hopper2.is_colliding()) or ($Rays/Right_Ledge_Hopper.is_colliding() and $Rays/Right_Ledge_Hopper2.is_colliding()) :
		if Input.is_action_pressed("move_jump"):
			velocity.y = wall_ride
	velocity.y += gravity
	
	#Rotate A bit to add JUICE
	if velocity.x > 5:
		rotation_degrees = lerp(rotation_degrees,3.0,12.0 * delta)
		anims.flip_h = true
	elif velocity.x < -5:
		rotation_degrees = lerp(rotation_degrees,-3.0,12.0 * delta)
		anims.flip_h = false
	else:
		rotation_degrees = lerp(rotation_degrees,0.0,12.0 * delta)
	
	
	var Interact_Intersections = [$Rays/Left_Interact.is_colliding(),$Rays/Right_Interact.is_colliding()]
	if Interact_Intersections.count(true) > 0 and can_move:
		if Interact_Intersections[0] and !Interact_Intersections[1]:
			if $Rays/Left_Interact.get_collider().is_in_group("INTERACTABLE"):
				$Rays/Left_Interact.get_collider().pickedParent = self
				change_state("Carry")
		elif !Interact_Intersections[0] and Interact_Intersections[1]:
			if $Rays/Right_Interact.get_collider().is_in_group("INTERACTABLE"):
				$Rays/Right_Interact.get_collider().pickedParent = self
				change_state("Carry")
	
	move_and_slide()

func change_state(animation=null,flip=null,backwards=false,particles=false):
	
	if animation:
		if animation_player.current_animation != animation:
			if particles:
				var particle = CHANGE_PARTICLE.instantiate()
				particles.add_child(particle)
				particle.global_position = global_position
			
			if !backwards:
				animation_player.play(animation)
			else:
				animation_player.play_backwards(animation)
				await animation_player.animation_finished
				animation_player.play("Idle")
	if flip:
		anims.flip_h = flip

func hurt():
	change_state("Damaged",null,false,true)
	can_move = false
	stun_recover_timer.start()


func _on_stun_recover_timer_timeout():
	can_move = true
	change_state("Damaged",null,true,false)
