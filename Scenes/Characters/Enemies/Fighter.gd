extends Enemy

const PROJECTILE_BASIC = preload("res://Scenes/Props/Projectiles/projectile_basic.tscn")
const EXPLOSION = preload("res://Scenes/Props/Projectiles/explosion.tscn")


var DashFrom:Node2D
@onready var projectile_spawn = $Markers/Projectile_Spawn
@onready var dash_stop = $Timers/DashStop
@onready var visible_notify = $VISIBLE_NOTIFY
@onready var stun = $Timers/Stun
@onready var collision_shape_2d = $CollisionShape2D
@onready var stop_timer = $Timers/StopTimer

var delta
var RandomMoveTarget:Vector2



func _ready():
	collision_shape_2d.set_deferred("disabled",true)
	State = "SPAWN"
	DAMAGED.connect(stunned)
	DEAD.connect(dead)
	var choice = randi_range(1,3)
	anims.play("fighter"+str(choice))
	SPEED = 20

func _physics_process(del):
	delta = del
	if State == "SPAWN":
		move_to_center(del)
	elif State == "FOLLOW":
		move_towards_player()
	elif State == "EVADE":
		dash()
	elif State == "STABLE":
		move_stable()
	elif State == "STUN":
		velocity = Vector2.ZERO

func _on_projectile_detector_body_entered(body):
	if State != "STUN" and State != "SPAWN":
		if body.is_in_group("PROJECTILE"):
			if body.creator != self:
				var choice = randi_range(0,2)
				if choice ==0 :
					State = "EVADE"
					DashFrom = body
					dash_stop.start()
		elif body.is_in_group("ENTITY"):
			State = "EVADE"
			DashFrom = body
			dash_stop.start()


func _on_dash_stop_timeout():
	State = "FOLLOW"


func _on_random_movement_timeout():
	if State != "STUN":
		var choice = randi_range(0,3)
		if choice != 0:
			RandomMoveTarget = Vector2(randi_range(-1,1),randi_range(-1,1))
			State = "STABLE"
		else:
			State = "FOLLOW"


func _on_visible_notify_screen_exited():
	State = "FOLLOW"


func _on_shoot_timeout():
	if State == "STABLE":
		var e = PROJECTILE_BASIC.instantiate()
		e.creator = self
		e.Type = "Red"
		GV.Projectile_Container.add_child(e)
		e.global_position = projectile_spawn.global_position
		e.rotation = rotation + PI/2
		e.dir = rotation + PI/2


func _on_stun_timeout():
	State = "STABLE"


func _on_stop_timer_timeout():
	collision_shape_2d.set_deferred("disabled",false)
	State = "FOLLOW"

#Custom Functions////////////////////////////////////
func dead():
	stun.stop()
	dash_stop.stop()
	collision_shape_2d.set_deferred("disabled",true)
	State = "STUN"
	var boom = EXPLOSION.instantiate()
	GV.Projectile_Container.add_child(boom)
	boom.global_position = global_position
	boom.z_index = z_index + 1
	await shake(20)
	queue_free()

func move_to_center(delta):
	velocity = velocity.lerp((GV.MAP_CENTER - global_position).normalized() * SPEED,SPEED*delta)
	move_and_slide()
	look_at(GV.MAP_CENTER)
	if visible_notify.is_on_screen():
		if stop_timer.time_left == 0:
			$Timers/StopTimer.start()

func stunned():
	State = "STUN"
	stun.start()

func move_towards_player():
	velocity = velocity.lerp((GV.Player.global_position - global_position).normalized() * SPEED,SPEED*delta)
	look_at(GV.Player.global_position)
	move_and_slide()

func dash():
	if DashFrom != null:
		velocity = velocity.lerp((global_position - DashFrom.global_position).normalized()*SPEED*5,delta*SPEED)
		look_at(GV.Player.global_position)
		move_and_slide()

func move_stable():
	look_at(GV.Player.global_position)
	velocity = Vector2(velocity.x+RandomMoveTarget.x,velocity.y+RandomMoveTarget.y)
	move_and_slide()
