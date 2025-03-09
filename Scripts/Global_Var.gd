extends Node


var States = {
	'Shield_Gen_State':100,
	'Engine_State':100,
	'Oxygen_State':100,
	'Weapons_State':100
	}

var Player

var FightScene:Node2D

var Deaths = 0

var Projectile_Container:Node2D
var Objects_Container:Node2D
var MAP_CENTER:Vector2
var LEVEL_NUMBER:int = 0
#Level [number]:([Name],[Enemies])
