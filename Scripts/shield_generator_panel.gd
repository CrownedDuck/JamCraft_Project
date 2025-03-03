extends CenterContainer

@onready var button_reaction = $Bg/Button_Reaction
@onready var animation_player = $Bg/Status_player
@onready var anim_1 = $Bg/Coords/Anim1
@onready var anim_2 = $Bg/Coords/Anim2
@onready var state = $Bg/State
@onready var button = $Bg/Button

@onready var minigames = $Bg/Minigames

var Minigame_Started:bool = false


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
	if !Minigame_Started:
		button.text = "Repair"
		button_reaction.play("Focus")


func _on_button_mouse_exited():
	if !Minigame_Started:
		button.text = ""
		button_reaction.play_backwards("Focus")


func _on_button_pressed():
	if !Minigame_Started:
		Minigame_Started = true
		button_reaction.play_backwards("Focus")
		button_reaction.play("Start_Minigame")


func _on_button_reaction_animation_finished(anim_name):
	if anim_name == "Start_Minigame":
		var mini = minigames.get_children()
		mini.shuffle()
		for i in mini:
			if i.is_in_group("minigame"):
				i.show()
				MINIGAME_ONE()
				break

func MINIGAME_ONE():
	DialogueManager.show_dialogue_balloon(load("res://Resources/Dialogues/Shield_Gen_Interactions.dialogue"),"MiniGame1")
