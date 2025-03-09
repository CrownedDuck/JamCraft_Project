class_name Level
extends Resource

const DUMMY = preload("res://Scenes/Characters/Enemies/dummy.tscn")
const FIGHTER = preload("res://Scenes/Characters/Enemies/Fighter.tscn")


@export var Name:String = "Level"
@export var Enemies:Array = [DUMMY]
@export var Field_Effect:String = "NONE"
@export var Enemy_Spawn_Dif:int = 0
@export var Dialogue_Played_at_Start:DialogueResource = null
