extends Node

# Referencias
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../Player/Camera2D/AudioStreamPlayer2D"
@export var attack_interval := 1.0
@export var sequence_lenght := 4
@onready var player: Player = $"../Player"
@onready var block_area: Area2D = $"../Player/Pivote/Sprite2D/BlockArea"
@onready var ray_cast_2d: RayCast2D = $"../Player/Pivote/RayCast2D"
@export var damage_window_duration := 5
# Estado de combate
var in_combat := false
var combats := {}  # enemy → data
var active_parry_targets: Array[Enemy] = []  # enemigos actualmente dentro del parry_area

# Señales
signal combat_started
signal combat_ended(success: bool, enemy: Enemy)

func _ready():
	block_area.parry_area_out.connect(_on_parry_area_out)
	block_area.parry_area_contact.connect(_on_parry_area_conect)
	player.hurtbox.damage_attempted.connect(_on_player_damage_attempted)

func start_combat(enemy: Enemy):
	in_combat = true
	combats.clear()
	active_parry_targets.clear()

	if not enemy.dead:
		enemy.can_get_hit = false
		enemy.state = enemy.State.ATTACKING

		var sequence := []
		for i in range(sequence_lenght):
			sequence.append(randi_range(1, 4))

		combats[enemy] = {
			"sequence": sequence,
			"index": 0,
			"input_received": false,
			"parry_conect": false,
			"failed": false
		}

	emit_signal("combat_started")

	for e in combats.keys():
		show_next_prompt(e)

func end_combat(success: bool, enemy: Enemy):
	if not combats.has(enemy):
		return

	enemy.state = enemy.State.ATTACKING

	if not success:
		player.get_node("HealthComponent").take_damage_v2(10.0)

	emit_signal("combat_ended", success, enemy)
	
	if player.has_node("PromptUI"):
		player.get_node("PromptUI").hide_prompt()

	combats.erase(enemy)
	active_parry_targets.erase(enemy)

	if combats.is_empty():
		in_combat = false

func _input(_event):
	if not in_combat:
		return

	# Recorre enemigos con los que se puede hacer parry
	for enemy in active_parry_targets:
		if not combats.has(enemy):
			continue
		var data = combats[enemy]
		if data["input_received"] or not data["parry_conect"]:
			continue

		var key: int = data["sequence"][data["index"]]
		if Input.is_action_just_pressed("parry_random%d" % key):
			print("Parry exitoso en %d" % key)
			data["input_received"] = true
			data["failed"] = false
			audio_stream_player_2d.play()
			data["index"] += 1
			var duration: float = enemy.animation_tree.get_animation(enemy.current_attack_anim).length
			await get_tree().create_timer(duration).timeout
			show_next_prompt(enemy)
		else:
			for i in range(1, 5):
				if i != key and Input.is_action_just_pressed("parry_random%d" % i):
					print("Parry fallido: tecla incorrecta")
					data["input_received"] = true
					data["failed"] = true  
			

func show_next_prompt(enemy: Enemy):
	if not combats.has(enemy):
		return

	var data = combats[enemy]
	var sequence = data["sequence"]
	var index = data["index"]

	if index >= sequence.size():
		if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == enemy:
			await start_damage_window(enemy)
		print("¡Secuencia completada!")
		return

	data["input_received"] = false
	data["failed"] = false
	var key = sequence[index]
	print("Presiona: ", key)

	player.get_node("PromptUI").show_prompt(str(key))

	await enemy.attack()

func _on_player_damage_attempted(from_position: Vector2, damage: float,enemy: Enemy) -> void:
	if not in_combat:
		return

	if enemy in combats:
		var data = combats[enemy]

		# Si el jugador hizo input y fue correcto, no hacer daño
		if data["input_received"] and data["failed"] == false:
			return

		# Si no recibió input o fue input fallido, chequear colisión para hacer daño
		# Verificar que hitbox del enemigo esté en la hurtbox del jugador
		player.take_damage(from_position)
		end_combat(false, enemy)

func _on_parry_area_conect():
	if ray_cast_2d.is_colliding():
		var enemy = ray_cast_2d.get_collider()
		if enemy in combats:
			combats[enemy]["parry_conect"] = true
			if not active_parry_targets.has(enemy):
				active_parry_targets.append(enemy)

func _on_parry_area_out():
	if ray_cast_2d.is_colliding():
		var enemy = ray_cast_2d.get_collider()
		if enemy in combats:
			combats[enemy]["parry_conect"] = false
			active_parry_targets.erase(enemy)

func start_damage_window(enemy: Enemy) -> void:
	enemy.can_get_hit = true
	await get_tree().create_timer(damage_window_duration).timeout
	if enemy and not enemy.dead:
		enemy.can_get_hit = false
		print("Fin de la ventana de daño para ", enemy.name)
