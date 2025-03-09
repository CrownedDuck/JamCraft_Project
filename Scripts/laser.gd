extends RayCast2D

var is_casting := false
@onready var root = $Line2D/Root
@onready var end = $Line2D/End
@onready var line_2d = $Line2D
@onready var animation_player = $AnimationPlayer


func _physics_process(delta):
	var cast_point := target_position
	force_raycast_update()
	
	if is_colliding():
		if get_collider().is_in_group("PROJECTILE"):
			get_collider().delete()
		else:
			if get_collider().is_in_group("ENTITY"):
				get_collider().damage(100)
			cast_point = to_local(get_collision_point())
			end.global_position = get_collision_point()
	else:
		end.position = target_position
	
	line_2d.points[1] = cast_point


func delete():
	animation_player.play("Delete")
	await animation_player.animation_finished
	queue_free()
