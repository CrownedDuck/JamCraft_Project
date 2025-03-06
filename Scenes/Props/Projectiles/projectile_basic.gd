extends CharacterBody2D

var Spawn_Pos:Vector2
var Spawn_Rot:float
var dir:float

var DMG:float = 10

var Type = "Normal"

const IMPACT_PARTICLE = preload("res://Scenes/Props/Particles/impact_particle.tscn")

var Spd = Vector2(0,-100)

func _ready():
	global_position = Spawn_Pos
	global_rotation = Spawn_Rot

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
		#queue_free()
