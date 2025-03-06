extends Control

@onready var button_reaction = $Bg/Button_Reaction
@onready var animation_player = $Bg/Status_player
@onready var anim_1 = $Bg/Coords/Anim1
@onready var anim_2 = $Bg/Coords/Anim2
@onready var state = $Bg/State
@onready var button = $Bg/Button
@onready var minigames = $Bg/Minigames

@onready var bg = $Bg

@onready var name_label = $Bg/Name

@onready var repair_ready_sound = $Sounds/RepairReadySound
@onready var random_await_timer = $Timers/RandomAwaitTimer
@onready var can_fix_timer = $Timers/CanFixTimer
@onready var minigame_indicator = $Bg/Minigames/Indicator

@export var STATE_CHECKED:String = "Shield_Gen_State"
@export var BUTTON_NAME:String = "SHIELD"

var Minigame_Started:bool = false

func _process(delta):
	state.text = str(GV.States[STATE_CHECKED]) + "%"

func _ready():
	GS.REPAIR_END.connect(stop)
	GS.REPAIR_START.connect(block)
	name_label.text = BUTTON_NAME
	
func change_displayed_anim():
	if GV.States[STATE_CHECKED]>= 85:
		await animation_player.animation_started
		anim_2.play("Normal")
		await anim_1.hidden
		animation_player.speed_scale = 1
		anim_1.play("Normal")
	
	elif GV.States[STATE_CHECKED] >= 65:
		await animation_player.animation_started
		anim_2.play("Medium")
		await anim_1.hidden
		animation_player.speed_scale = 0.7
		anim_1.play("Medium")
	
	elif GV.States[STATE_CHECKED] >= 35:
		await animation_player.animation_started
		anim_2.play("Damaged")
		await anim_1.hidden
		animation_player.speed_scale = 0.4
		anim_1.play("Damaged")
	
	elif GV.States[STATE_CHECKED] > 0:
		await animation_player.animation_started
		anim_2.play("Critical")
		await anim_1.hidden
		animation_player.speed_scale = randf_range(0.3,1)
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


func _on_button_mouse_entered():
	if !Minigame_Started and !button.disabled :
		button.text = "Repair"
		button_reaction.play("Focus")


func _on_button_mouse_exited():
	if !Minigame_Started and !button.disabled:
		button.text = ""
		button_reaction.play_backwards("Focus")


func _on_button_pressed():
	if !Minigame_Started:
		Minigame_Started = true
		button_reaction.play_backwards("Focus")
		button.text = ""
		button_reaction.play("Start_Minigame")
		GS.REPAIR_START.emit()
	else:
		print(can_fix_timer.time_left)
		if can_fix_timer.time_left != 0:
			minigame_indicator.color = "#00aa00"
			GS.REPAIR_END.emit()
			GV.States[STATE_CHECKED] += 25
			if GV.States[STATE_CHECKED] > 100:
				GV.States[STATE_CHECKED] = 100

func _on_button_reaction_animation_finished(anim_name):
	if anim_name == "Start_Minigame":
		random_await_timer.wait_time = randf_range(2,5)
		minigame_indicator.color = "#585858"
		random_await_timer.start()
	elif anim_name == "End_Minigame":
		button.disabled = false


func _on_random_await_timer_timeout():
	repair_ready_sound.play()
	can_fix_timer.start()
	minigame_indicator.color = "#dccb38"
	button.text = "CLICK"


func _on_can_fix_timer_timeout():
	minigame_indicator.color = "#dc0038"
	print("FAILED FIX")
	shake(25)
	GV.States[STATE_CHECKED] -= 25
	if GV.States[STATE_CHECKED] < 0:
		GV.States[STATE_CHECKED] = 0
	GS.REPAIR_END.emit()

func stop():
	button.text = ""
	button.disabled = true
	Minigame_Started = false
	random_await_timer.stop()
	can_fix_timer.stop()
	await get_tree().create_timer(0.1).timeout
	button_reaction.play("End_Minigame")
	

func block():
	if !Minigame_Started:
		button_reaction.play_backwards("Focus")
		button.disabled = true
		minigame_indicator.color = "#585858"
		Minigame_Started = false
		await get_tree().create_timer(0.1).timeout
		button_reaction.play("Block_View")
		await button_reaction.animation_finished
		button.text = "SEALED"

func shake(amount):
	for i in range(amount):
		bg.position.x = randf_range(-1,1)
		bg.position.y = randf_range(-1,1)
		await get_tree().create_timer(0.01).timeout
	bg.position.x = 0
	bg.position.y = 0
