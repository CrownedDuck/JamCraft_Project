extends Enemy

@onready var visible_notify = $VISIBLE_NOTIFY
@onready var collision_shape_2d = $CollisionShape2D
@onready var stop_timer = $Timers/StopTimer

const EXPLOSION = preload("res://Scenes/Props/Projectiles/explosion.tscn")

func _ready():
	DEAD.connect(dead)
	State = "SPAWN"
	collision_shape_2d.set_deferred("disabled",true)

func _physics_process(delta):
	if State == "SPAWN":
		move_to_center(delta)

func move_to_center(delta):
	velocity = velocity.lerp((GV.MAP_CENTER - global_position).normalized() * SPEED,SPEED*delta)
	move_and_slide()
	look_at(GV.MAP_CENTER)
	if visible_notify.is_on_screen():
		if stop_timer.time_left == 0:
			$Timers/StopTimer.start()

func dead():
	collision_shape_2d.set_deferred("disabled",true)
	State = "STUN"
	var boom = EXPLOSION.instantiate()
	GV.Projectile_Container.call_deferred("add_child", boom)
	boom.global_position = global_position
	boom.z_index = z_index + 1
	await shake(20)
	GV.Player.restore_energy()
	queue_free()


func _on_stop_timer_timeout():
	State = "FOLLOW"
	collision_shape_2d.set_deferred("disabled",false)
