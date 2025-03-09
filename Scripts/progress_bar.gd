extends VBoxContainer

@onready var text = $Text
@onready var progress_bar = $ProgressBar

@export var TEXT:String
@export var VARIANT:String
@export var MAX_VALUE:float

func _ready():
	text.text = TEXT
	progress_bar.max_value = MAX_VALUE

func _process(delta):
	if VARIANT == "BLASTER":
		progress_bar.value = MAX_VALUE - GV.Player.shoot_cooldown.time_left
	elif VARIANT == "SHIELD":
		progress_bar.value = GV.Player.SHIELD_ENERGY
