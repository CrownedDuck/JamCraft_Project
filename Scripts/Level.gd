class_name Level
extends Resource

const DUMMY = preload("res://Scenes/Characters/Enemies/dummy.tscn")
const FIGHTER = preload("res://Scenes/Characters/Enemies/Fighter.tscn")


@export var Name:String = "Level"
@export var Enemies:Dictionary = {0:[DUMMY,"TOP"]}
@export var Field_Effect:String = "NONE"
