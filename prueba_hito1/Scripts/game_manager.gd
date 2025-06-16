extends Node

@export var enemie_list: Array[Enemy] = []
@onready var player: Player = $"../Player"
@onready var player_health = $"../Player/HealthComponent"
@onready var ui: CanvasLayer = $"../UI"


var game_ended = false

func _ready():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemie_list.append(enemy)
	print(enemie_list)
	for e in enemie_list:
		e.enemy_died.connect(_on_enemy_died)
	player_health.player_died.connect(_on_player_died)

func _on_enemy_died():
	if game_ended:
		return
	enemie_list = enemie_list.filter(func(e): return not e.dead)
	if enemie_list.is_empty():
		_show_victory()

func _on_player_died():
	if game_ended:
		return
	_show_defeat()

func _show_victory():
	game_ended = true
	ui.show_message("¡VICTORIA!",true)

func _show_defeat():
	game_ended = true
	ui.show_message("HAS MUERTO",false)
