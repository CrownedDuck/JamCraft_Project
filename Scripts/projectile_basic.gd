extends CharacterBody2D

var dir:float

var DMG:float = 10

var creator:Node2D

var Type = "Energy"
@onready var anims = $Anims
@onready var fire_trail = $FireTrail

const IMPACT_PARTICLE = preload("res://Scenes/Props/Particles/impact_particle.tscn")

var Spd = Vector2(0,-100)

func _ready():
	anims.play(Type)
	fire_trail.play(Type)
	

func _physics_process(delta):
	var collision_info = move_and_collide((Spd * delta).rotated(dir))
	if collision_info:
		Spd = Spd.bounce(collision_info.get_normal())


func _on_hit_scanner_body_entered(body):
	if body.is_in_group("ENTITY"):
		body.damage(DMG)
		var e = IMPACT_PARTICLE.instantiate()
		body.particles.add_child(e)
		e.global_position = body.global_position
		e.look_at(global_position)
		e.z_index = body.z_index + 1
		queue_free()
	elif body.is_in_group("ABSORB"):
		var e = IMPACT_PARTICLE.instantiate()
		body.add_child(e)
		e.global_position = global_position
		e.look_at(global_position)
		e.z_index = body.z_index + 1
		queue_free()

func delete():
	var e = IMPACT_PARTICLE.instantiate()
	GV.Projectile_Container.call_deferred("add_child",e)
	e.global_position = global_position
	e.look_at(global_position)
	e.z_index = z_index + 1
	queue_free()
