extends Node


var States = {
	'Shield_Gen_State':100,
	'Engine_State':100,
	'Oxygen_State':100,
	'Weapons_State':100
	}

var OVERHEAT_AMOUNT:int = 0
var OVERHEATED:bool = false

var Player

var Projectile_Container:Node2D
var MAP_CENTER:Vector2
var LEVEL_NUMBER:int = 0
#Level [number]:([Name],[Enemies])
