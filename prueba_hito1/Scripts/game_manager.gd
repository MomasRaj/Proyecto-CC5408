extends Node

@onready var player: Player = $"../Player"
@onready var player_health: HealthComponent = $"../Player/HealthComponent"
@onready var ui: CanvasLayer = $"../UI"

var enemie_list: Array[Enemy] = []
var game_ended = false

func _ready():
	enemie_list.clear()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead:
			enemie_list.append(enemy)
			print(enemie_list)
			enemy.enemy_died.connect(_on_enemy_died)

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
	if get_tree().current_scene.scene_file_path == "res://Escenas/Main2.tscn":
		ui.show_message("¡VICTORIA!", true)
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://ui/credits.tscn")
	else:	
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Escenas/Main2.tscn")

func _show_defeat():
	game_ended = true
	ui.show_message("HAS MUERTO", false)
