extends Enemy

const PROJECTILE_BASIC = preload("res://Scenes/Props/Projectiles/projectile_basic.tscn")
const EXPLOSION = preload("res://Scenes/Props/Projectiles/explosion.tscn")
const LASER = preload("res://Scenes/Props/Projectiles/laser.tscn")

var DashFrom:Node2D
@onready var projectile_spawn = $Markers/Projectile_Spawn
@onready var visible_notify = $VISIBLE_NOTIFY
@onready var collision_shape_2d = $CollisionShape2D

@onready var stun = $Timers/Stun
@onready var stop_timer = $Timers/StopTimer
@onready var random_movement = $Timers/RandomMovement
@onready var charge_laser = $Timers/ChargeLaser

@onready var laser_charge_particles = $Markers/Projectile_Spawn/LaserChargePart
@onready var laser_container = $Markers/LaserContainer
@onready var laser_restart = $Timers/Laser_Restart

var can_shoot_laser = true
var delta
var RandomMoveTarget:Vector2



func _ready():
	HP = 150
	collision_shape_2d.set_deferred("disabled",true)
	State = "SPAWN"
	GS.PLAYER_DEAD.connect(on_player_dead)
	DAMAGED.connect(stunned)
	DEAD.connect(dead)
	SPEED = 20

func _physics_process(del):
	laser_charge_particles.speed_scale = 1 + (charge_laser.wait_time - charge_laser.time_left)
	laser_charge_particles.amount = 8 + (charge_laser.wait_time - charge_laser.time_left)*5
	delta = del
	if State == "SPAWN":
		move_to_center()
	elif State == "STABLE":
		move_stable()
	elif State == "LEAVE":
		leave()



func _on_random_movement_timeout():
	if charge_laser.time_left == 0:
		RandomMoveTarget = Vector2(randi_range(-1,1),randi_range(-1,1))
		State = "STABLE"


func _on_visible_notify_screen_exited():
	if State != "LEAVE":
		State = "STABLE"


func _on_stun_timeout():
	State = "STABLE"


func _on_stop_timer_timeout():
	collision_shape_2d.set_deferred("disabled",false)
	State = "STABLE"

#Custom Functions////////////////////////////////////
func dead():
	stun.stop()
	collision_shape_2d.set_deferred("disabled",true)
	State = "STUN"
	var boom = EXPLOSION.instantiate()
	GV.Projectile_Container.call_deferred("add_child",boom)
	boom.global_position = global_position
	boom.z_index = z_index + 1
	GV.Player.restore_energy()
	await shake(20)
	queue_free()


func move_towards_player():
	velocity = velocity.lerp((GV.Player.global_position - global_position).normalized() * SPEED,SPEED*delta)
	var direction = (GV.Player.global_position - global_position) 
	var targetRotation = direction.angle()
	rotation = lerp_angle(rotation, targetRotation, 5 * delta)
	move_and_slide()

func move_to_center():
	velocity = velocity.lerp((GV.MAP_CENTER - global_position).normalized() * SPEED*2,SPEED*delta)
	move_and_slide()
	
	var direction = (GV.MAP_CENTER - global_position) 
	var targetRotation = direction.angle()
	rotation = lerp_angle(rotation, targetRotation, 5 * delta)
	
	if visible_notify.is_on_screen():
		if stop_timer.time_left == 0:
			$Timers/StopTimer.start()

func stunned():
	State = "STUN"
	stun.start()

func move_stable():
	if global_position.distance_to(GV.Player.global_position) < 60:
		var direction = (GV.Player.global_position - global_position) 
		var targetRotation = direction.angle()
		rotation = lerp_angle(rotation, targetRotation, 5 * delta)
		velocity = Vector2(velocity.x+RandomMoveTarget.x,velocity.y+RandomMoveTarget.y)
		move_and_slide()
	else:
		move_towards_player()
		if charge_laser.time_left == 0 and can_shoot_laser == true:
			charge_laser.start()
			laser_charge_particles.emitting = true
			can_shoot_laser = false

func leave():
	velocity = velocity.lerp((global_position - GV.MAP_CENTER).normalized() * SPEED,SPEED*delta)
	velocity = velocity.lerp((GV.Player.global_position - global_position).normalized() * SPEED,delta)
	look_away(GV.MAP_CENTER)
	move_and_slide()

func on_player_dead():
	stun.stop()
	stop_timer.stop()
	charge_laser.stop()
	random_movement.stop()
	laser_restart.stop()
	if laser_container.get_child_count() != 0:
		laser_container.get_child(0).delete()
	
	collision_shape_2d.set_deferred("disabled",true)
	State = "LEAVE"


func _on_laser_charge_timeout():
	var laser = LASER.instantiate()
	laser_container.call_deferred("add_child",laser)
	laser_charge_particles.emitting = false
	await get_tree().create_timer(3).timeout
	if laser_container.get_child_count() != 0:
		laser_container.get_child(0).delete()
	laser_restart.start()




func _on_laser_restart_timeout():
	can_shoot_laser = true
