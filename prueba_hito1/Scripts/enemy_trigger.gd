extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var player: Player = get_node("/root/MainEscene/Player")
@onready var combat_manager = get_node("/root/MainEscene/CombatManager")
@onready var self_enemy: Enemy = owner as Enemy  # Asume que el dueño del Area2D es el enemigo

var timer := Timer.new()

@export var MAX_COMBAT_DISTANCE := 120.0

func _ready() -> void:
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(_on_block_time_over)
	add_child(timer)

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not timer.is_stopped():
			timer.stop()
		timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		timer.stop()  # Si el jugador sale antes del timeout, cancelar

func _on_block_time_over() -> void:
	if self_enemy.dead:
		return

	# Comprobamos si el jugador sigue dentro del rango
	if player.global_position.distance_to(self_enemy.global_position) <= MAX_COMBAT_DISTANCE:
		combat_manager.start_combat(self_enemy)
