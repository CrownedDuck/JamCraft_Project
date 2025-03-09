extends Node
@onready var start = $Start
@onready var fight_1 = $Fight1
@onready var fight_2 = $Fight2

func change_music(music):
	if music != "Start":
		stopp(start)
	elif music != "Fight1":
		stopp(fight_1)
	elif music != "Fight2":
		stopp(fight_2)
	startt(get_node(music))


func stopp(music):
	if music.volume_db > -40:
		for i in range(35):
			music.volume_db -= 1
			if get_tree():
				await get_tree().create_timer(0.01)
	music.stop()

func startt(music):
	if !music.playing:
		music.play()
		for i in range(35):
			print(music.volume_db)
			music.volume_db += 1
			if get_tree():
				await get_tree().create_timer(0.01)
