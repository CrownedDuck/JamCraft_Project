extends CenterContainer

@onready var button_reaction = $Bg/Button_Reaction
@onready var animation_player = $Bg/Status_player
@onready var anim_1 = $Bg/Coords/Anim1
@onready var anim_2 = $Bg/Coords/Anim2
@onready var state = $Bg/State
@onready var button = $Bg/Button

var Loops = 0


func change_displayed_anim():
	if GV.Shield_Gen_State >= 85:
		await animation_player.animation_started
		anim_2.play("Normal")
		await anim_1.hidden
		animation_player.speed_scale = 0.5
		anim_1.play("Normal")
	
	elif GV.Shield_Gen_State >= 65:
		await animation_player.animation_started
		anim_2.play("Medium")
		await anim_1.hidden
		animation_player.speed_scale = 0.55
		anim_1.play("Medium")
	
	elif GV.Shield_Gen_State >= 35:
		await animation_player.animation_started
		anim_2.play("Damaged")
		await anim_1.hidden
		animation_player.speed_scale = 0.6
		anim_1.play("Damaged")
	
	elif GV.Shield_Gen_State > 0:
		await animation_player.animation_started
		anim_2.play("Critical")
		await anim_1.hidden
		animation_player.speed_scale = 0.7
		anim_1.play("Critical")
	
	else:
		await animation_player.animation_started
		anim_2.play("Destroyed")
		await anim_1.hidden
		animation_player.speed_scale = 0.1
		anim_1.play("Destroyed")



func _on_animation_player_animation_finished(anim_name):
	animation_player.play("Loop")
	change_displayed_anim()
	state.text = str(GV.Shield_Gen_State) + "%"


func _on_button_mouse_entered():
	button.text = "Repair"
	button_reaction.play("Focus")


func _on_button_mouse_exited():
	button.text = ""
	button_reaction.play_backwards("Focus")
