extends CharacterBody2D

var pickedParent:Node
@export var OBJECT:String

var gravity:float = 12.0
const max_gravity:float = 14.5

const max_speed:float = 200
const acceleration:float = 8
const friction:float = 10

func _ready():
	$AnimatedSprite2D.play(OBJECT)

func _physics_process(delta):
	if pickedParent:
		$CollisionShape2D.set_deferred("disabled",true)
		velocity = lerp(velocity, (pickedParent.picked_point.global_position - global_position).normalized() * max_speed, delta*acceleration)
		gravity = 0
	else:
		gravity = lerp(gravity, max_gravity, 12.0 * delta)
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, delta*acceleration*friction)
		velocity.y += gravity
	move_and_slide()
func _unhandled_input(event):
	if pickedParent:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				pickedParent.change_state("Carry",null,true,false)
				pickedParent = null
				velocity = (get_global_mouse_position() - global_position).normalized() * max_speed
				$CollisionShape2D.set_deferred("disabled",false)
