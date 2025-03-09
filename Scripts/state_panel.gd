extends Control

@onready var button_reaction = $Bg/Button_Reaction
@onready var state = $Bg/State
@onready var button = $Bg/Button
@onready var minigames = $Bg/Minigames

@onready var bg = $Bg

@onready var name_label = $Bg/Name


@onready var random_await_timer = $Timers/RandomAwaitTimer
@onready var can_fix_timer = $Timers/CanFixTimer
@onready var minigame_indicator = $Bg/Minigames/Indicator
@onready var progress = $Bg/Progress

@export var STATE_CHECKED:String = "Shield_Gen_State"
@export var BUTTON_NAME:String = "SHIELD"

@onready var repair_done_sound = $Sounds/RepairDoneSound
@onready var repair_failed_sound = $Sounds/RepairFailedSound
@onready var repair_ready_sound = $Sounds/RepairReadySound
var Minigame_Started:bool = false

func _process(delta):
	state.text = str(GV.States[STATE_CHECKED]) + "%"
	progress.value = GV.States[STATE_CHECKED]
	check_color()

func _ready():
	GS.REPAIR_END.connect(stop)
	GS.REPAIR_START.connect(block)
	name_label.text = BUTTON_NAME

func check_color():
	if GV.States[STATE_CHECKED] > 80:
		progress.modulate = "#ffffff"
	elif GV.States[STATE_CHECKED] > 60:
		progress.modulate = "#ffd96e"
	elif GV.States[STATE_CHECKED] > 35:
		progress.modulate = "#eb8a00"
	elif GV.States[STATE_CHECKED] > 0:
		progress.modulate = "#e90000"
	else:
		hide()
		button.disabled = true
		progress.modulate = "#000000"


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
			GV.States[STATE_CHECKED] = 100
			repair_done_sound.play()

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
	repair_failed_sound.play()
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
