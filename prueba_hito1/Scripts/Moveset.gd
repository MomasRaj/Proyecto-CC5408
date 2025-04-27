extends Node
class_name MoveData

var Moves : Dictionary = {
	["U"] : "entry_jump",
	["D"] : "entry_down",
	["R"] : "entry_right",
	["L"] : "entry_left",
	["A"] : "entry_attack",
	["I"] : "Idle",
}
var Specials : Dictionary = {
	["D", "R", "A"]: "Proyectile" 
}
