extends Node

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@export var attack_interval := 1.0
@export var sequence_lenght := 4
@onready var player: Player = $"../Player"
@onready var enemy_1: Enemy = $"../Enemy1"
@onready var combat_manager: Node = $"."

var in_combat := false
var current_index := 0
var sequence := []
var player_blocking := false
var attack_timer : Timer = null
var prompt_timer: Timer
var prompt_key := 0
var input_received := false
var parry_area_contact: bool = false

signal combat_started
signal combat_ended(success: bool)

func _ready():
	player.parry_zone_contact.connect(_on_parry_zone_contact)
	prompt_timer = Timer.new()
	prompt_timer.wait_time = attack_interval
	prompt_timer.one_shot = true
	prompt_timer.timeout.connect(_on_prompt_timeout)
	add_child(prompt_timer)

func start_combat():
	in_combat = true
	player_blocking = true
	current_index = 0
	sequence = []
	for i in range(sequence_lenght):
		sequence.append(randi_range(1, 4))
	emit_signal("combat_started")
	show_next_prompt()

func end_combat(success: bool):
	in_combat = false
	prompt_timer.stop()
	emit_signal("combat_ended", success)
	# Ocultar el prompt UI si existe
	if player and player.has_node("PromptUI"):
		player.get_node("PromptUI").hide_prompt()

func register_input(key: int):
	if not in_combat or not player_blocking or not parry_area_contact:
		return

	if input_received:
		return

	if key == prompt_key and parry_area_contact:
		print("Parry exitoso en %d" % key)
		input_received = true
		prompt_timer.stop()
		audio_stream_player_2d.play()
		current_index += 1
		var duration = enemy_1.animation_tree.get_animation(enemy_1.current_attack_anim).length
		await get_tree().create_timer(duration).timeout
		show_next_prompt()
	else:
		
		end_combat(false)
	parry_area_contact=false

func show_next_prompt():
	if current_index >= sequence.size():
		end_combat(true)
		print("¡Secuencia completada!")
		enemy_1.take_damage()
		player.get_node("PromptUI").get_node("PromptLabel").hide()
		return
	prompt_key = sequence[current_index]
	input_received = false
	print("Presiona: ", prompt_key)
	player.get_node("PromptUI").show_prompt(str(prompt_key))
	enemy_1.attack()
	prompt_timer.start()

func _on_prompt_timeout():
	if not input_received:
		print("¡Fallaste el parry!")
		end_combat(false)

func set_player_blocking(blocking: bool):
	player_blocking = blocking

func is_player_turn():
	return in_combat

func _on_parry_zone_contact():
	parry_area_contact = true
