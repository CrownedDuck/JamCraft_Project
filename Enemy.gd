class_name Enemy
extends CharacterBody2D

@onready var impact_sound = $Sounds/ImpactSound
@onready var particles = $Particles
@onready var anims = $Anims


@export var HP:int = 100



func damage(amount):
	HP -= amount
	impact_sound.play()
	shake(10)
	if HP <= 0:
		queue_free()

func shake(amount):
	for i in range(amount):
		anims.offset.x = randf_range(-0.5,0.5)
		anims.offset.y = randf_range(-0.5,0.5)
		await get_tree().create_timer(0.01).timeout
	anims.offset.x = 0
	anims.offset.y = 0
