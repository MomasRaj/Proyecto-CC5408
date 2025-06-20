extends Node

#Referencia a nodos
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@export var attack_interval := 1.0
@export var sequence_lenght := 4
@onready var player: Player = $"../Player"
@onready var combat_manager: Node = $"."
@onready var block_area: Area2D = $"../Player/Pivote/Sprite2D/BlockArea"
@onready var ray_cast_2d: RayCast2D = $"../Player/Pivote/RayCast2D"

#Variables de combate
var in_combat := false
var input_received := false
var parry_conect = false

#Timers
var attack_timer : Timer = null
#Variables auxiliares
var prompt_key := 0
var current_index := 0
var sequence := []

#Enemigos
var enemy_list:=[]

signal combat_started
signal combat_ended(success: bool)

func _ready():
	block_area.parry_area_out.connect(_on_parry_area_out)
	block_area.parry_area_contact.connect(_on_parry_area_conect)
	player.hurtbox.damage_attempted.connect(_on_player_damage_attempted)
	
func start_combat():
	enemy_list =[]
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead:
			enemy_list.append(enemy)
			enemy.can_get_hit=false
			enemy.state=enemy.State.ATTACKING
	in_combat = true
	current_index = 0
	sequence = []
	for i in range(sequence_lenght):
		sequence.append(randi_range(1, 4)) 
	emit_signal("combat_started")
	show_next_prompt()

func end_combat(success: bool):
	for enemy in enemy_list:	
		enemy.state=enemy.State.ATTACKING
	if success == false:
		var salud_componente = player.get_node("HealthComponent")
		salud_componente.take_damage_v2(10.0)

	in_combat = false
	emit_signal("combat_ended", success)
	# Ocultar el prompt UI si existe
	if player and player.has_node("PromptUI"):
		player.get_node("PromptUI").hide_prompt()


func _input(_event):
	if not in_combat or not parry_conect or input_received:
		return
	if Input.is_action_just_pressed("parry_random%d"%prompt_key) and parry_conect and enemy_list.size() and ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() in enemy_list:
		print("Parry exitoso en %d" % prompt_key)
		input_received = true
		audio_stream_player_2d.play()
		current_index += 1
		var collider= ray_cast_2d.get_collider()
		var duration = collider.animation_tree.get_animation(collider.current_attack_anim).length
		await get_tree().create_timer(duration).timeout
		
		show_next_prompt()


func show_next_prompt():
	if current_index >= sequence.size():
		if ray_cast_2d.is_colliding():
			var collider = ray_cast_2d.get_collider()
			if collider is Enemy and collider in enemy_list:
				collider.can_get_hit=true
				collider.take_damage()
		print("¡Secuencia completada!")
		end_combat(true)
		player.get_node("PromptUI").get_node("PromptLabel").hide()
		return
	
	input_received = false
	prompt_key = sequence[current_index]
	print("Presiona: ", prompt_key)
	
	player.get_node("PromptUI").show_prompt(str(prompt_key))
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider is Enemy and collider in enemy_list:
			await collider.attack()

func _on_player_damage_attempted(from_position: Vector2, damage: float) -> void:
	if not in_combat or input_received:
		return
	player.take_damage(from_position)
	end_combat(false)

func _on_parry_area_conect():
	parry_conect=true

func _on_parry_area_out():
	parry_conect=false
