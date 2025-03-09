extends Area2D
@onready var explosion_particles = $ExplosionParticles
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	explosion_particles.emitting = true
	GS.SHAKE_CAMERA.emit()
	await get_tree().create_timer(0.3).timeout
	collision_shape_2d.set_deferred("disabled",true)

func _on_body_entered(body):
	if body.is_in_group("ENTITY"):
		body.damage(40)



func _on_animation_player_animation_finished(anim_name):
	queue_free()
